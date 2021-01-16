DROP TABLE IF EXISTS `Centro_Medico`.Flags;
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Flags(
			`varName` VARCHAR(255) NOT NULL,
			`value` BOOLEAN NOT NULL DEFAULT FALSE,
			PRIMARY KEY (`varName`),
			UNIQUE INDEX `varName_UNIQUE` (`varName` ASC)
		);
insert into 
	`Centro_Medico`.Flags(`varName`,`value`) 
VALUES 
	('EnableCheckMinPsicologoMedicoSecretario',1);
select * from `Centro_Medico`.Flags;

DROP FUNCTION IF EXISTS `getCosteBaseServicio`;
DELIMITER //
CREATE FUNCTION getCosteBaseServicio(tipoServicio INT,direccionCentro VARCHAR(255))
RETURNS FLOAT
BEGIN
	DECLARE coste FLOAT;
    SELECT Servicios.precioBase INTO coste from Servicios where Servicios.tipo = tipo and Servicios.direccionCentro = direccionCentro LIMIT 1;
	RETURN coste;
END; //
DELIMITER ;


DROP FUNCTION IF EXISTS `getSumPenalizacionPatalogiasCliente`;
DELIMITER //
CREATE FUNCTION getSumPenalizacionPatalogiasCliente (dniCliente CHAR(9))
RETURNS FLOAT
BEGIN
	DECLARE sum FLOAT;
    SELECT SUM(Patologias.penalizacion) INTO sum from Patologias where Patologias.dniCliente = dniCliente;
	RETURN sum;
END; //
DELIMITER ;


DROP FUNCTION IF EXISTS `getEdadCliente`;
DELIMITER //
CREATE FUNCTION getEdadCliente (dniCliente CHAR(9))
RETURNS FLOAT
BEGIN
	DECLARE currentDate DATE;
	DECLARE currentYear INT;
    DECLARE currentMonth INT;
    DECLARE bornYear INT;
    DECLARE bornMonth INT;
    DECLARE result INT;
    SET currentDate = NOW();
	SET currentYear = YEAR(currentDate);
	SET currentMonth = MONTH(currentDate);
    select YEAR(Clientes.fechaNacimiento) into bornYear from Clientes where Clientes.dni = dniCliente;
    select MONTH(Clientes.fechaNacimiento) into bornMonth from Clientes where Clientes.dni = dniCliente;
	SET result = currentYear - bornYear - ((currentMonth-bornMonth) < 0);
	RETURN result;
END; //
DELIMITER ;

DROP FUNCTION IF EXISTS `calcCoste`;
DELIMITER //
CREATE FUNCTION calcCoste ( dniCliente CHAR(9),tipoServicio INT,direccionCentro VARCHAR(255), fechaIni DATE, fechaFin DATE)
RETURNS FLOAT
BEGIN
   DECLARE penalizaciones FLOAT;
   DECLARE clientAge INT;
   DECLARE ageFactor FLOAT;
   DECLARE daysDiff INT;
   DECLARE costePerYear INT;
   DECLARE costeBase FLOAT;
   DECLARE costeFinal FLOAT;
   SELECT getSumPenalizacionPatalogiasCliente(dniCliente) INTO penalizaciones;
   SELECT getCosteBaseServicio(tipoServicio, direccionCentro) INTO costeBase;
   SELECT getEdadCliente(dniCliente) INTO clientAge;
   CASE 
	  WHEN clientAge < 18 THEN SET ageFactor = 0.8;
      WHEN clientAge >= 18 AND clientAge < 40 THEN SET ageFactor = 1;
      WHEN clientAge >= 40 AND clientAge < 65 THEN SET ageFactor = 1.20;
      WHEN clientAge > 65 THEN SET ageFactor = 1.40;
      ELSE BEGIN END;
    END CASE;
    
    SET daysDiff = DATEDIFF(fechaFin, fechaIni);
	CASE 
      WHEN (daysDiff < 365) THEN SET costePerYear = 20;
      WHEN (daysDiff >= 365) AND daysDiff < 730 THEN SET costePerYear = 35;
      WHEN daysDiff >= 730 THEN SET costePerYear = 40;
      ELSE BEGIN END;
    END CASE; 
   
   SET costeFinal = costeBase*ageFactor + penalizaciones + costePerYear;
   RETURN costeFinal;
END; //
DELIMITER ; 

DROP FUNCTION IF EXISTS `thereIsMinPsicologoMedicoSecretario`;
DELIMITER //
CREATE FUNCTION thereIsMinPsicologoMedicoSecretario (direccion VARCHAR(255))
RETURNS BOOLEAN
BEGIN
	DECLARE isEnabled BOOLEAN;
	DECLARE sumPsicologos INT;
	DECLARE sumSecretarios INT;
    DECLARE sumMedicos INT;

    SELECT Flags.`value` INTO isEnabled FROM Flags where Flags.varName = 'EnableCheckMinPsicologoMedicoSecretario';
    IF isEnabled = FALSE THEN
		return TRUE;
	END IF;
    
	SELECT COUNT(ETC.dniEmpleado) INTO sumPsicologos 
		from Empleado_Trabaja_Centro as ETC 
		inner join EmpleadoPsicologo as EP on EP.dniEmpleado = ETC.dniEmpleado
		inner join Empleados as E on E.dni = ETC.dniEmpleado
		where 
			ETC.direccionCentro = direccion
			AND
            DATEDIFF(E.fechaFin, Now()) > 0;
        
    SELECT COUNT(ETC.dniEmpleado) INTO sumSecretarios 
		from Empleado_Trabaja_Centro as ETC 
        inner join EmpleadoSecretario as ES on ES.dniEmpleado = ETC.dniEmpleado
        inner join Empleados as E on E.dni = ETC.dniEmpleado
		where 
			ETC.direccionCentro = direccion
			AND
            DATEDIFF(E.fechaFin, Now()) > 0;
        
	SELECT COUNT(ETC.dniEmpleado) INTO sumMedicos 
		from Empleado_Trabaja_Centro as ETC 
		inner join EmpleadoMedico as EM on EM.dniEmpleado = ETC.dniEmpleado
		inner join Empleados as E on E.dni = ETC.dniEmpleado
		where 
			ETC.direccionCentro = direccion
			AND
            DATEDIFF(E.fechaFin, Now()) > 0;
        
	RETURN ((sumPsicologos > 0) AND (sumSecretarios > 0) AND (sumMedicos > 0));
END; //
DELIMITER ;


DROP FUNCTION IF EXISTS `IsEmpleadoSecretario`;
DELIMITER //
CREATE FUNCTION IsEmpleadoSecretario (dniEmpleado CHAR(9))
RETURNS FLOAT
BEGIN
	DECLARE exist BOOLEAN;
    SELECT (COUNT(ES.dniEmpleado) > 0) INTO exist from EmpleadoSecretario as ES  where ES.dniEmpleado = dniEmpleado;
	RETURN exist;
END; //
DELIMITER ;


DROP FUNCTION IF EXISTS `IsEmpleadoMedico`;
DELIMITER //
CREATE FUNCTION IsEmpleadoMedico (dniEmpleado CHAR(9))
RETURNS FLOAT
BEGIN
	DECLARE exist BOOLEAN;
    SELECT (COUNT(EM.dniEmpleado) > 0) INTO exist from EmpleadoMedico as EM  where EM.dniEmpleado = dniEmpleado;
	RETURN exist;
END; //
DELIMITER ;

DROP FUNCTION IF EXISTS `IsEmpleadoPsicologo`;
DELIMITER //
CREATE FUNCTION IsEmpleadoPsicologo (dniEmpleado CHAR(9))
RETURNS FLOAT
BEGIN
	DECLARE exist BOOLEAN;
    SELECT (COUNT(EP.dniEmpleado) > 0) INTO exist from EmpleadoPsicologo as EP  where EP.dniEmpleado = dniEmpleado;
	RETURN exist;
END; //
DELIMITER ;

DROP FUNCTION IF EXISTS `IsEmpleadoAdministrador`;
DELIMITER //
CREATE FUNCTION IsEmpleadoAdministrador (dniEmpleado CHAR(9))
RETURNS FLOAT
BEGIN
	DECLARE exist BOOLEAN;
    SELECT (COUNT(EA.dniEmpleado) > 0) INTO exist from EmpleadoAdministrador as EA  where EA.dniEmpleado = dniEmpleado;
	RETURN exist;
END; //
DELIMITER ;

DROP FUNCTION IF EXISTS `calcSalary`;
DELIMITER //
CREATE FUNCTION calcSalary (dniEmpleado CHAR(9))
RETURNS FLOAT
BEGIN
	DECLARE sum FLOAT;
    DECLARE temp FLOAT;
    SET sum := 0;
    IF IsEmpleadoSecretario(dniEmpleado) = TRUE THEN
		SELECT SUM(C_C_S_E.Coste*S.`%secretario`) INTO temp FROM Servicios AS S
			INNER JOIN Cliente_Compra_Servicios_AtravesDe_Empleados AS C_C_S_E ON S.tipo = C_C_S_E.tipoServicio
			INNER JOIN Empleados AS E ON E.dni = C_C_S_E.dniEmpleado
			WHERE E.dni = dniEmpleado;
        SET sum := sum + temp;
    END IF;
	IF IsEmpleadoMedico(dniEmpleado) = TRUE THEN
		SELECT SUM(C_C_S_E.Coste*S.`%medico`) INTO temp FROM Servicios AS S
			INNER JOIN Cliente_Compra_Servicios_AtravesDe_Empleados AS C_C_S_E ON S.tipo = C_C_S_E.tipoServicio
			INNER JOIN Empleados AS E ON E.dni = C_C_S_E.dniEmpleado
			WHERE E.dni = dniEmpleado;
        SET sum := sum + temp;
    END IF;
    IF IsEmpleadoPsicologo(dniEmpleado) = TRUE THEN
		SELECT SUM(C_C_S_E.Coste*S.`%psicologo`) INTO temp FROM Servicios AS S
			INNER JOIN Cliente_Compra_Servicios_AtravesDe_Empleados AS C_C_S_E ON S.tipo = C_C_S_E.tipoServicio
			INNER JOIN Empleados AS E ON E.dni = C_C_S_E.dniEmpleado
			WHERE E.dni = dniEmpleado;
        SET sum := sum + temp;
    END IF;
	IF IsEmpleadoAdministrador(dniEmpleado) = TRUE THEN
		SELECT SUM(C_C_S_E.Coste*S.`%administrador`) INTO temp FROM Servicios AS S
			INNER JOIN Cliente_Compra_Servicios_AtravesDe_Empleados AS C_C_S_E ON S.tipo = C_C_S_E.tipoServicio
			INNER JOIN Empleados AS E ON E.dni = C_C_S_E.dniEmpleado
			WHERE E.dni = dniEmpleado;
        SET sum := sum + temp;
    END IF;
    
    return sum;
END; //
DELIMITER ;


/*
excludeTable{
	1 = PSICOLOGO,
    2 = MEDICO,
    3 = SECRETARIO
    4 = ADMINISTRADOR
}
*/
DROP FUNCTION IF EXISTS `isInOtherEmpleadoTable`;    
DELIMITER //
CREATE FUNCTION isInOtherEmpleadoTable (dniEmpleado CHAR(9), excludeTable INT)
RETURNS BOOLEAN
BEGIN
	DECLARE sum INT;
    DECLARE temp INT;
    SET sum := 0;
    CASE excludeTable
		 WHEN 1 THEN -- 'PSICOLOGO'
			SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoMedico as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoAdministrador as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoSecretario as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
		WHEN 2 THEN -- 'MEDICO'
			SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoPsicologo as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoAdministrador as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoSecretario as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
		WHEN 3 THEN -- 'SECRETARIO'
			SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoMedico as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoAdministrador as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoPsicologo as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
		WHEN 4 THEN -- 'ADMINISTRADOR'
			SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoMedico as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoAdministrador as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
            SELECT COUNT(E.dniEmpleado) INTO temp FROM EmpleadoSecretario as E WHERE E.dniEmpleado = dniEmpleado ;
            SET sum := sum + temp;
		ELSE BEGIN END;
    END CASE;
	RETURN (sum > 0);
END; //
DELIMITER ;






DROP TABLE IF EXISTS `Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados;

DROP TABLE IF EXISTS `Centro_Medico`.Centros_Recibe_AsistenciaExterior;
DROP TABLE IF EXISTS `Centro_Medico`.Empleado_Trabaja_Centro;

DROP TABLE IF EXISTS `Centro_Medico`.Servicios;
	DROP TABLE IF EXISTS `Centro_Medico`.TipoServicios;
        
DROP TABLE IF EXISTS `Centro_Medico`.Centros;

DROP TABLE IF EXISTS `Centro_Medico`.AsistenciaExterior;
	DROP TABLE IF EXISTS `Centro_Medico`.ServiciosExternos;
	DROP TABLE IF EXISTS `Centro_Medico`.EmpresasExternas;

DROP TABLE IF EXISTS `Centro_Medico`.Patologias;
DROP TABLE IF EXISTS `Centro_Medico`.Clientes;


DROP TABLE IF EXISTS `Centro_Medico`.EmpleadoSecretario;
DROP TABLE IF EXISTS `Centro_Medico`.EmpleadoMedico;
	DROP TABLE IF EXISTS `Centro_Medico`.MedicoEspecializacion;
DROP TABLE IF EXISTS `Centro_Medico`.EmpleadoPsicologo;
DROP TABLE IF EXISTS `Centro_Medico`.EmpleadoAdministrador;
DROP TABLE IF EXISTS `Centro_Medico`.Empleados;


-- -----------------------------------------------------
-- Table `Centro_Medico`.`AsistenciaExterior`
-- -----------------------------------------------------

		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`ServiciosExternos`
		-- -----------------------------------------------------
		CREATE TABLE IF NOT EXISTS `Centro_Medico`.ServiciosExternos(
			id INT NOT NULL AUTO_INCREMENT,
			tipo VARCHAR(55) NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `tipo_UNIQUE` (`tipo` ASC)
		);

			DELIMITER //
			CREATE TRIGGER `TRIGGER_ServiciosExternos_BI_toUpperTipo` BEFORE INSERT on `Centro_Medico`.ServiciosExternos
			FOR EACH ROW
			BEGIN
				set NEW.tipo := UPPER(NEW.tipo);
			END//
			DELIMITER ;

		insert into 
			`Centro_Medico`.ServiciosExternos(`tipo`) 
		VALUES 
			('Limpieza'),
			('Informática');
		-- select * from `Centro_Medico`.ServiciosExternos;
        
        -- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`EmpresasExternas`
		-- -----------------------------------------------------
		CREATE TABLE IF NOT EXISTS `Centro_Medico`.EmpresasExternas(
			id INT NOT NULL AUTO_INCREMENT,
			empresa VARCHAR(55) NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `empresa_UNIQUE` (`empresa` ASC)
		);

			DELIMITER //
			CREATE TRIGGER `TRIGGER_EmpresasExternas_BI_toUpperEmpresa` BEFORE INSERT on `Centro_Medico`.EmpresasExternas
			FOR EACH ROW
			BEGIN
				set NEW.empresa := UPPER(NEW.empresa);
			END//
			DELIMITER ;

		insert into 
			`Centro_Medico`.EmpresasExternas(`empresa`) 
		VALUES 
			("Limpiezas Paco"),
			("Informatica Matrix");
		-- select * from `Centro_Medico`.ServiciosExternos;
        
CREATE TABLE IF NOT EXISTS `Centro_Medico`.AsistenciaExterior(/*Entidad : 'AsistenciaExterior'*/
	tipo INT NOT NULL/*ENUM ('Limpieza','Informática')*/,
    empresa INT NOT NULL/*VARCHAR(55)*/,
    PRIMARY KEY (`tipo`, `empresa`),
    -- Removido porque entonces no permite hacer, por ej, (1,"Informatica Matrix") y luego (2,"Informatica Matrix")
    -- UNIQUE INDEX `empresa_UNIQUE` (`empresa` ASC), -- necesario para crear una clave foranea de ella más adelante
    CONSTRAINT `FK_ServiciosExternos_tipo__AsistenciaExterior`
    FOREIGN KEY (`tipo`)
    REFERENCES `Centro_Medico`.ServiciosExternos(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    
	CONSTRAINT `FK_EmpresasExternas_empresa__AsistenciaExterior`
    FOREIGN KEY (`empresa`)
    REFERENCES `Centro_Medico`.EmpresasExternas(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

insert into 
	`Centro_Medico`.AsistenciaExterior(`tipo`,`empresa`) 
VALUES 
	(1, 1),
	(2, 2);
insert into `Centro_Medico`.AsistenciaExterior(`tipo`,`empresa`) VALUES (1, 2); -- Correcto
select `SE`.tipo,`EE`.empresa from `Centro_Medico`.AsistenciaExterior as `AE` 
	inner join `Centro_Medico`.ServiciosExternos as `SE` on `AE`.tipo = `SE`.id
    inner join `Centro_Medico`.EmpresasExternas as `EE` on `AE`.empresa = `EE`.id;

/* PRUEBAS
	insert into `Centro_Medico`.AsistenciaExterior(`tipo`,`empresa`) VALUES (2, 2); -- Error
*/



-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Centros(/*Entidad : 'Centro'*/
    direccion VARCHAR(255) NOT NULL,
    horarioInicio TIME NOT NULL,
    horarioFin TIME NOT NULL,
    PRIMARY KEY(`direccion`),
    UNIQUE INDEX `direccion_UNIQUE` (`direccion` ASC)
    /*,CONSTRAINT `CHECK_Centros__horarioInicio_lowerThan_horarioFin` CHECK ( TIMEDIFF(horarioFin,horarioInicio) > 0 )*/ -- No funca
);

-- select TIMEDIFF('14:00','08:00') > 0 ;
	DELIMITER //
	CREATE TRIGGER `TRIGGER_Centros_BI_toUpperDireccion_And_hInicio_lt_hFin` BEFORE INSERT on `Centro_Medico`.Centros
	FOR EACH ROW
	BEGIN
		set NEW.direccion := UPPER(NEW.direccion);
        IF  TIMEDIFF(NEW.horarioFin,NEW.horarioInicio) < 0 THEN
			signal sqlstate '20002' set message_text = 'Centros: El horarioFin debe ser mayor que el horarioInicio seteado';
		END IF;
	END//
	DELIMITER ;
    

insert into 
	`Centro_Medico`.Centros(`direccion`,`horarioInicio`,`horarioFin`) 
VALUES 
	('Dirección','08:00', '14:00');
    
/* PRUEBAS
	insert into 
		`Centro_Medico`.Centros(`direccion`,`horarioInicio`,`horarioFin`) 
	VALUES 
		('Dirección2','09:00', '15:00'); -- Ese último para pruebas
	insert into `Centro_Medico`.Centros(`direccion3`,`horarioInicio`,`horarioFin`) VALUES ('Dirección2','14:00', '08:00'); -- Error
    select * from `Centro_Medico`.Centros;
*/


-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros_Recibe_AsistenciaExterior`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Centros_Recibe_AsistenciaExterior(/*Relación : 'Recibe'*/
	tipoAsistenciaExterior INT NOT NULL,
	empresaAsistenciaExterior INT NOT NULL,
    direccionCentro VARCHAR(255) NOT NULL,
    fecha DATETIME NOT NULL,
    coste INT UNSIGNED NOT NULL,
    PRIMARY KEY(`tipoAsistenciaExterior`,`empresaAsistenciaExterior`,`direccionCentro`,`fecha`),
    
    CONSTRAINT `FK_AsistenciaExterior_tipoAsistenciaExterior__C_Recibe_A`
    FOREIGN KEY (`tipoAsistenciaExterior`)
    REFERENCES `Centro_Medico`.AsistenciaExterior(`tipo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    
    CONSTRAINT `FK_AsistenciaExterior_empresaAsistenciaExterior__C_Recibe_A`
    FOREIGN KEY (`empresaAsistenciaExterior`)
    REFERENCES `Centro_Medico`.AsistenciaExterior(`empresa`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    
    CONSTRAINT `FK_Centro_direccionCentro__C_Recibe_A`
    FOREIGN KEY (`direccionCentro`)
    REFERENCES `Centro_Medico`.Centros(`direccion`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


-- -----------------------------------------------------
-- Table `Centro_Medico`.`Servicios`
-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`TipoServicios`
		-- -----------------------------------------------------
		CREATE TABLE IF NOT EXISTS `Centro_Medico`.TipoServicios(
			id INT NOT NULL AUTO_INCREMENT,
			tipo VARCHAR(70) NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `tipo_UNIQUE` (`tipo` ASC)
		);
        
			DELIMITER //
			CREATE TRIGGER `TRIGGER_TipoServicios_BI_toUpperTipo` BEFORE INSERT on `Centro_Medico`.TipoServicios
			FOR EACH ROW
			BEGIN
				set NEW.tipo := UPPER(NEW.tipo);
			END//
			DELIMITER ;
            
		
		insert into 
			`Centro_Medico`.TipoServicios(`tipo`)
		VALUES
			('Carnet de conducir'),
			('Certificado médico'),
			('Renovación del carnet'),
			('Canjes'),
			('Certificado para seguridad privada'),
			('Certificado de armas'),
			('Certificado de perros peligrosos'),
			('Certificado de buceo');
        
/*ENUM  ('Carnet de conducir','Certificado médico','Renovación del carnet','Canjes', 'Certificado para seguridad privada',
    'Certificado de armas', 'Certificado de perros peligrosos', 'Certificado de buceo')*/
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Servicios(/*Entidad : 'Servicios'*/
    direccionCentro VARCHAR(255) NOT NULL,
    tipo INT NOT NULL, -- Se tuvo que cambiar porque si va a ser clave foranea, debe ser unique y entonces, por ej, (dir1,tipo1), (dir2,tipo1) deja de ser posible.
    precioBase FLOAT NOT NULL,
    `%administrador` FLOAT UNSIGNED NOT NULL,/*FLOAT(2,2) is deprecated*/
    `%secretario` FLOAT UNSIGNED NOT NULL,
	`%psicologo` FLOAT UNSIGNED NOT NULL,
    `%medico` FLOAT UNSIGNED NOT NULL,
    PRIMARY KEY(`direccionCentro`,`tipo`),
    
    CONSTRAINT `FK_Centros_direccionCentro__Servicios`
    FOREIGN KEY (`direccionCentro`)
    REFERENCES `Centro_Medico`.Centros(`direccion`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    
    CONSTRAINT `FK_TipoServicios_tipo__Servicios`
    FOREIGN KEY (`tipo`)
    REFERENCES `Centro_Medico`.TipoServicios(`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

	DELIMITER //
	CREATE TRIGGER `TRIGGER_Servicios_BI_toUpperDireccionAndSumEQ1` BEFORE INSERT on `Centro_Medico`.Servicios
	FOR EACH ROW
	BEGIN
		DECLARE sum FLOAT;
		set NEW.direccionCentro := UPPER(NEW.direccionCentro);
		set sum := NEW.`%administrador`+ NEW.`%secretario`+ NEW.`%psicologo`+ NEW.`%medico`;
		IF sum <> 1 THEN
			signal sqlstate '20001' set message_text = 'Servicios: El sumatorio de los porcentajes debe ser 1';
		END IF;
	END//
	DELIMITER ;

insert into 
	`Centro_Medico`.Servicios(`direccionCentro`,`tipo`,`precioBase`,`%administrador`,`%secretario`,`%psicologo`,`%medico`)
VALUES
	('Dirección',1,665,0.25,0.25,0.25,0.25),
	('Dirección',2,60,0,0,0.5,0.5),
	('Dirección',3,24,0.5,0.5,0,0),
	('Dirección',4,60,0,1,0,0),
	('Dirección',5,550,0.25,0.25,0.25,0.25),
	('Dirección',6,25,0,0.33,0.34,0.33),
	('Dirección',7,30,0.25,0.25,0.25,0.25),
	('Dirección',8,280,0.25,0.25,0.25,0.25);
    
/* PRUEBAS
	insert into 
		`Centro_Medico`.Servicios(`direccionCentro`,`tipo`,`precioBase`,`%administrador`,`%secretario`,`%psicologo`,`%medico`)
	VALUES
		('Dirección2',1,665,0.25,0.25,0.25,0.25),
		('Dirección2',2,60,0,0,0.5,0.5),
		('Dirección2',3,24,0.5,0.5,0,0),
		('Dirección2',4,60,0,1,0,0),
		('Dirección2',5,550,0.25,0.25,0.25,0.25),
		('Dirección2',6,25,0,0.33,0.34,0.33),
		('Dirección2',7,30,0.25,0.25,0.25,0.25),
		('Dirección2',8,280,0.25,0.25,0.25,0.25);
	select direccionCentro,TS.tipo,`%administrador`,`%secretario`,`%psicologo`,`%medico` from `Centro_Medico`.Servicios as S inner join TipoServicios as TS on TS.id = S.tipo ;
*/

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Clientes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Clientes(/*Entidad : 'Clientes'*/
    nombre VARCHAR(255) NOT NULL,
    dni CHAR(9) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    fechaNacimiento DATE NOT NULL,
    PRIMARY KEY(`dni`),
    UNIQUE INDEX `dni_UNIQUE` (`dni` ASC)
);
	DELIMITER //
	CREATE TRIGGER `TRIGGER_Clientes_BI_toUpper` BEFORE INSERT on `Centro_Medico`.Clientes
	FOR EACH ROW
	BEGIN
		set NEW.nombre := UPPER(NEW.nombre);
		set NEW.dni := UPPER(NEW.dni);
	END//
	DELIMITER ;

insert into 
			`Centro_Medico`.Clientes(`nombre`,`dni`,`telefono`,`fechaNacimiento`)
		VALUES
			('Pedro','12345678Z','123456789',STR_TO_DATE('25-11-1993','%d-%m-%Y') ),
            ('Jose','87654321Z','987654321','1995-05-15');
select * from `Centro_Medico`.Clientes;

/*ToDo : ¿Comprobar que el DNI introducido es correcto?*/

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Patalogia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Patologias(/*Entidad : 'Patologias'*/
    nombre VARCHAR(255) NOT NULL,
    dniCliente CHAR(9) NOT NULL,
    penalizacion FLOAT DEFAULT 1 NOT NULL,
    PRIMARY KEY(`dniCliente`,`nombre`),
    
    CONSTRAINT `FK_Clientes_dni__Patologias`
    FOREIGN KEY (`dniCliente`)
    REFERENCES `Centro_Medico`.Clientes(`dni`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
	DELIMITER //
	CREATE TRIGGER `TRIGGER_Patologias_BI_toUpper` BEFORE INSERT on `Centro_Medico`.Patologias
	FOR EACH ROW
	BEGIN
		set NEW.nombre := UPPER(NEW.nombre);
		set NEW.dniCliente := UPPER(NEW.dniCliente);
	END//
	DELIMITER ;


insert into 
			`Centro_Medico`.Patologias(`nombre`,`dniCliente`,`penalizacion`)
		VALUES
			('Patologia1','12345678Z',5),
			('Patologia2','12345678Z',3.5);
insert into 
			`Centro_Medico`.Patologias(`nombre`,`dniCliente`,`penalizacion`)
		VALUES
			('Patologia1','87654321Z',2),
			('Patologia2','87654321Z',4.5);    
select * from `Centro_Medico`.Patologias;

/* PRUEBAS
	insert into `Centro_Medico`.Patalogias(`nombre`,`dniCliente`) VALUES ('Patologia1','12345678Z'); -- Error
*/


-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleados`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Empleados(/*Entidad : 'Empleados'*/
    dni CHAR(9) NOT NULL,
    fechaIni DATETIME NOT NULL,
    fechaFin DATETIME NOT NULL,
    PRIMARY KEY(`dni`,fechaIni),
    UNIQUE INDEX `dni_UNIQUE` (`dni` ASC)
);
	
insert into 
	`Centro_Medico`.Empleados(`dni`,`fechaIni`,`fechaFin`)
VALUES
	('12345678Z',STR_TO_DATE('25-11-1993','%d-%m-%Y'),STR_TO_DATE('01-05-2025','%d-%m-%Y') ),
	('87654321Z','1995-05-15','2030-06-24'),
	('57614987G','2010-05-15','2025-04-13'),
	('47523978F','2018-05-15','2020-04-13');
    
    -- select (TIMESTAMP('1995-05-15 14:55:05') - TIMESTAMP('1995-05-15 14:55:00')) > 0
    DELIMITER //
	CREATE TRIGGER `TRIGGER_Empleados_BI_toUpper_And_fIni_lt_fFin` BEFORE INSERT on `Centro_Medico`.Empleados
	FOR EACH ROW
	BEGIN
		set NEW.dni := UPPER(NEW.dni);
        IF (TIMESTAMP(NEW.fechaFin) - TIMESTAMP(NEW.fechaIni)) < 0 THEN
			signal sqlstate '20006' set message_text = 'Empleados : La fechaFin debe ser mayor que la fechaIni seteada';
        END IF;
	END//
	DELIMITER ;

	CREATE TABLE IF NOT EXISTS `Centro_Medico`.EmpleadoSecretario(
		dniEmpleado CHAR(9) NOT NULL,
		PRIMARY KEY(`dniEmpleado`),
		UNIQUE INDEX `dniEmpleado_UNIQUE` (`dniEmpleado` ASC),
		
		CONSTRAINT `FK_Empleadoss_dniEmpleado__EmpleadoSecretario`
		FOREIGN KEY (`dniEmpleado`)
		REFERENCES `Centro_Medico`.Empleados(`dni`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
	);
    
		-- -----------------------------------------------------
		-- Auxiliar Table `Centro_Medico`.`MedicoEspecializacion`
		-- -----------------------------------------------------
		CREATE TABLE IF NOT EXISTS `Centro_Medico`.MedicoEspecializacion(
			id INT NOT NULL AUTO_INCREMENT,
			especializacion VARCHAR(70) NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `tipo_UNIQUE` (`especializacion` ASC)
		);
        
		insert into 
			`Centro_Medico`.MedicoEspecializacion(`especializacion`)
		VALUES
			('Oftalmólogo'),
			('Dermatólogo'),
			('Cirujano Plástico');
            
	CREATE TABLE IF NOT EXISTS `Centro_Medico`.EmpleadoMedico(
		dniEmpleado CHAR(9) NOT NULL,
		especializacion /*ENUM('OFTALMÓLOGO', 'DERMATÓLOGO',  'CIRUJANO PLÁSTICO')*/ INT NOT NULL,
		PRIMARY KEY(`dniEmpleado`),
		UNIQUE INDEX `dniEmpleado_UNIQUE` (`dniEmpleado` ASC),
		
		CONSTRAINT `FK_Empleados_dniEmpleado__EmpleadoMedico`
		FOREIGN KEY (`dniEmpleado`)
		REFERENCES `Centro_Medico`.Empleados(`dni`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
        CONSTRAINT `FK_MedicoEspecializacion_especializacion__EmpleadoMedico`
		FOREIGN KEY (`especializacion`)
		REFERENCES `Centro_Medico`.MedicoEspecializacion(`id`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
	);
    
	CREATE TABLE IF NOT EXISTS `Centro_Medico`.EmpleadoPsicologo(
		dniEmpleado CHAR(9) NOT NULL,
		PRIMARY KEY(`dniEmpleado`),
		UNIQUE INDEX `dniEmpleado_UNIQUE` (`dniEmpleado` ASC),
		
		CONSTRAINT `FK_Empleadoss_dniEmpleado__EmpleadoPsicologo`
		FOREIGN KEY (`dniEmpleado`)
		REFERENCES `Centro_Medico`.Empleados(`dni`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
	);
    
	CREATE TABLE IF NOT EXISTS `Centro_Medico`.EmpleadoAdministrador(
		dniEmpleado CHAR(9) NOT NULL,
		PRIMARY KEY(`dniEmpleado`),
		UNIQUE INDEX `dniEmpleado_UNIQUE` (`dniEmpleado` ASC),
		
		CONSTRAINT `FK_Empleados_dniEmpleado__EmpleadoAdministrador`
		FOREIGN KEY (`dniEmpleado`)
		REFERENCES `Centro_Medico`.Empleados(`dni`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
	);	
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoSecretario_BI_NotInOtherEmpleadoTable` BEFORE INSERT on `Centro_Medico`.EmpleadoSecretario
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
            if isInOtherEmpleadoTable(NEW.dniEmpleado , 3) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoSecretario :El empleado ya se encuentra en otra tabla subclase de Empleados';
            END IF;
		END//
		DELIMITER ;
        DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoSecretario_BU_NotInOtherEmpleadoTable` BEFORE UPDATE on `Centro_Medico`.EmpleadoSecretario
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
            if isInOtherEmpleadoTable(NEW.dniEmpleado , 3) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoSecretario :El empleado ya se encuentra en otra tabla subclase de Empleados';
            END IF;
		END//
		DELIMITER ;
        
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoMedico_BI_NotInOtherEmpleadoTable` BEFORE INSERT on `Centro_Medico`.EmpleadoMedico
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
			if isInOtherEmpleadoTable(NEW.dniEmpleado , 2) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoMedico :El empleado ya se encuentra en otra tabla subclase de Empleados';
			END IF;
		END//
		DELIMITER ;
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoMedico_BU_NotInOtherEmpleadoTable` BEFORE UPDATE on `Centro_Medico`.EmpleadoMedico
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
			if isInOtherEmpleadoTable(NEW.dniEmpleado , 2) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoSecretario :El empleado ya se encuentra en otra tabla subclase de Empleados';
			END IF;
		END//
		DELIMITER ;
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoPsicologo_BI_NotInOtherEmpleadoTable` BEFORE INSERT on `Centro_Medico`.EmpleadoPsicologo
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
			if isInOtherEmpleadoTable(NEW.dniEmpleado , 1) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoPsicologo :El empleado ya se encuentra en otra tabla subclase de Empleados';
			END IF;
		END//
		DELIMITER ;
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoPsicologo_BU_NotInOtherEmpleadoTable` BEFORE UPDATE on `Centro_Medico`.EmpleadoPsicologo
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
			if isInOtherEmpleadoTable(NEW.dniEmpleado , 1) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoPsicologo :El empleado ya se encuentra en otra tabla subclase de Empleados';
			END IF;
		END//
		DELIMITER ;
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoAdministrador_BI_NotInOtherEmpleadoTable` BEFORE INSERT on `Centro_Medico`.EmpleadoAdministrador
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
			if isInOtherEmpleadoTable(NEW.dniEmpleado , 4) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoAdministrador :El empleado ya se encuentra en otra tabla subclase de Empleados';
			END IF;
		END//
		DELIMITER ;
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpleadoAdministrador_BU_NotInOtherEmpleadoTable` BEFORE UPDATE on `Centro_Medico`.EmpleadoAdministrador
		FOR EACH ROW
		BEGIN
			set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
			if isInOtherEmpleadoTable(NEW.dniEmpleado , 4) THEN
				signal sqlstate '20006' set message_text = 'EmpleadoAdministrador :El empleado ya se encuentra en otra tabla subclase de Empleados';
			END IF;
		END//
		DELIMITER ;

    insert into 
		`Centro_Medico`.EmpleadoSecretario(`dniEmpleado`)
	VALUES
		('12345678Z');
	insert into 
		`Centro_Medico`.EmpleadoMedico(`dniEmpleado`,`especializacion`)
	VALUES
		('57614987G',1);
	insert into 
		`Centro_Medico`.EmpleadoPsicologo(`dniEmpleado`)
	VALUES
		('87654321Z');
        
    /* PRUEBAS
		select isInOtherEmpleadoTable('87654321Z',3); -- == TRUE
		insert into 
			`Centro_Medico`.EmpleadoSecretario(`dniEmpleado`)
		VALUES
			('87654321Z'); -- Error
    */
	

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Cliente_Compra_Servicios_AtravesDe_Empleados`
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS `Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados(/*Relacion : 'Compra'*/
    dniEmpleado CHAR(9) NOT NULL,
    dniCliente CHAR(9) NOT NULL,
    direccionCentro VARCHAR(255) NOT NULL,
    tipoServicio INT NOT NULL,
    fecha DATE NOT NULL,
    fechaCad DATE NOT NULL,
    `coste` FLOAT NOT NULL, /*Atributo Calculado*/
    PRIMARY KEY(`dniEmpleado`,`dniCliente`,`direccionCentro`,`tipoServicio`,`fecha`),
    
    CONSTRAINT `FK_Empleados_dniEmpleado__C_Compra_S_AD_E`
		FOREIGN KEY (`dniEmpleado`)
		REFERENCES `Centro_Medico`.Empleados(`dni`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	
	CONSTRAINT `FK_Clientes_dniCliente__C_Compra_S_AD_E`
		FOREIGN KEY (`dniCliente`)
		REFERENCES `Centro_Medico`.Clientes(`dni`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
	CONSTRAINT `FK_Centros_direccionCentro__C_Compra_S_AD_E`
		FOREIGN KEY (`direccionCentro`)
		REFERENCES `Centro_Medico`.Centros(`direccion`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	
    CONSTRAINT `FK_Servicios_tipoServicio__C_Compra_S_AD_E`
		FOREIGN KEY (`tipoServicio`)
		REFERENCES `Centro_Medico`.Servicios(`tipo`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

    DELIMITER //
	CREATE TRIGGER `TRIGGER_C_Compra_S_AD_E_BI_toUpper_AND_f_lt_fCad_AND_coste_calc` BEFORE INSERT on `Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados
	FOR EACH ROW
	BEGIN
		set NEW.dniEmpleado := UPPER(NEW.dniEmpleado);
		set NEW.dniCliente := UPPER(NEW.dniCliente);
		set NEW.direccionCentro := UPPER(NEW.direccionCentro);
        IF (TIMESTAMP(NEW.fechaCad) - TIMESTAMP(NEW.fecha)) < 0 THEN
			signal sqlstate '20004' set message_text = 'Cliente_Compra_Servicios_AtravesDe_Empleados : La fechaCad debe ser mayor que la fecha seteada';
        END IF;
		set NEW.coste := calcCoste(NEW.dniCliente,NEW.tipoServicio,NEW.direccionCentro,NEW.fecha,NEW.fechaCad);
	END//
	DELIMITER ;

insert into 
	`Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados
    (`dniEmpleado`,`dniCliente`,`direccionCentro`,`tipoServicio`,`fecha`,`fechaCad`)
VALUES
	('12345678Z','12345678Z','Dirección',1,STR_TO_DATE('14-01-2021','%d-%m-%Y'),'2025-01-14' ),
	('12345678Z','87654321Z','Dirección',4,STR_TO_DATE('14-01-2021','%d-%m-%Y'),'2025-01-14' );
select * from `Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados;

/* PRUEBAS
select calcCoste('12345678Z',1,'Dirección',STR_TO_DATE('14-01-2021','%d-%m-%Y'),'2025-01-14' );

insert into 
	`Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados
    (`dniEmpleado`,`dniCliente`,`direccionCentro`,`tipoServicio`,`fecha`,`fechaCad`)
VALUES
	('87654321Z','87654321Z','Dirección2',1,'2025-01-14',STR_TO_DATE('14-01-2021','%d-%m-%Y') ); -- Error
*/
-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleado_Trabaja_Centro`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Empleado_Trabaja_Centro(/*Relación : 'Trabaja'*/
    dniEmpleado CHAR(9) NOT NULL,
    direccionCentro VARCHAR(255) NOT NULL,
    tipoServicio INT NOT NULL,
    fecha DATETIME NOT NULL,
    `salario/día` FLOAT NULL, /*Atributo Calculado*/
    PRIMARY KEY(`dniEmpleado`,`direccionCentro`,`tipoServicio`, `fecha`),
    
    CONSTRAINT `FK_Empleados_dniEmpleado__E_Trabaja_C`
		FOREIGN KEY (`dniEmpleado`)
		REFERENCES `Centro_Medico`.Empleados(`dni`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
        
	CONSTRAINT `FK_Servicios_direccionCentro__E_Trabaja_C`
		FOREIGN KEY (`direccionCentro`)
		REFERENCES `Centro_Medico`.Servicios(`direccionCentro`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	
    CONSTRAINT `FK_Servicios_tipoServicio__E_Trabaja_C`
		FOREIGN KEY (`tipoServicio`)
		REFERENCES `Centro_Medico`.Servicios(`tipo`)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

-- SET GLOBAL enabledCheckMinimoEmpleado_Trabaja_Centro = 1; -- No funca
	DELIMITER //
	CREATE TRIGGER `TRIGGER_E_Trabaja_C_BI_check` BEFORE INSERT on `Centro_Medico`.Empleado_Trabaja_Centro
	FOR EACH ROW
	BEGIN
		IF thereIsMinPsicologoMedicoSecretario(NEW.direccionCentro) = FALSE THEN
			signal sqlstate '20005' set message_text = 'Empleado_Trabaja_Centro: Num. min. profesionals failing.Fix it disabling 1º the flag <EnableCheckMinPsicologoMedicoSecretario>';
        END IF;        
	END//
	DELIMITER ;
    
    DELIMITER //
	CREATE TRIGGER `TRIGGER_E_Trabaja_C_BD_check` BEFORE DELETE on `Centro_Medico`.Empleado_Trabaja_Centro
	FOR EACH ROW
	BEGIN
		IF thereIsMinPsicologoMedicoSecretario(OLD.direccionCentro) = FALSE THEN
			signal sqlstate '20005' set message_text = 'Empleado_Trabaja_Centro: Num. min. profesionals failing.Fix it disabling 1º the flag <EnableCheckMinPsicologoMedicoSecretario>';
        END IF;
	END//
	DELIMITER ;
    
	DELIMITER //
	CREATE TRIGGER `TRIGGER_E_Trabaja_C_BU_check` BEFORE UPDATE on `Centro_Medico`.Empleado_Trabaja_Centro
	FOR EACH ROW
	BEGIN
		IF thereIsMinPsicologoMedicoSecretario(NEW.direccionCentro) = FALSE THEN
			signal sqlstate '20005' set message_text = 'Empleado_Trabaja_Centro: Num. min. profesionals failing.Fix it disabling 1º the flag <EnableCheckMinPsicologoMedicoSecretario>';
        END IF;
	END//
	DELIMITER ;


UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = FALSE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";
insert into 
	`Centro_Medico`.Empleado_Trabaja_Centro(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('12345678Z','DIRECCIÓN',1, NOW()),
	('57614987G','DIRECCIÓN',1, NOW()),
	('87654321Z','DIRECCIÓN',1, NOW());
    
UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = TRUE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";

/*
insert into 
	`Centro_Medico`.Empleado_Trabaja_Centro(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('47523978F','DIRECCIÓN2',2, NOW()); -- Error

UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = FALSE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";
insert into 
	`Centro_Medico`.Empleado_Trabaja_Centro(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('12345678Z','DIRECCIÓN2',1, NOW()),
	('57614987G','DIRECCIÓN2',1, NOW()),
	('87654321Z','DIRECCIÓN2',1, NOW());
    
UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = TRUE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";

insert into 
	`Centro_Medico`.Empleado_Trabaja_Centro(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('47523978F','DIRECCIÓN2',2, NOW()); -- Ok
    
*/
-- El administrador a la hora de computar salarios, ejecutaría esta llamada:
-- SELECT 'El salario sería',calcSalary('12345678Z');




