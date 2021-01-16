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

-- -----------------------------------------------------
-- Table `Centro_Medico`.`AsistenciaExterior`
-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`ServiciosExternos`
		-- -----------------------------------------------------
		DELIMITER //
		CREATE TRIGGER `TRIGGER_ServiciosExternos_BI_toUpperTipo` BEFORE INSERT on `Centro_Medico`.ServiciosExternos
		FOR EACH ROW
		BEGIN
			set NEW.tipo := UPPER(NEW.tipo);
		END//
		DELIMITER ;

	    -- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`EmpresasExternas`
		-- -----------------------------------------------------
		DELIMITER //
		CREATE TRIGGER `TRIGGER_EmpresasExternas_BI_toUpperEmpresa` BEFORE INSERT on `Centro_Medico`.EmpresasExternas
		FOR EACH ROW
		BEGIN
			set NEW.empresa := UPPER(NEW.empresa);
		END//
		DELIMITER ;
        
-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros`
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros_Recibe_AsistenciaExterior`
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Servicios`
-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`TipoServicios`
		-- -----------------------------------------------------
		DELIMITER //
		CREATE TRIGGER `TRIGGER_TipoServicios_BI_toUpperTipo` BEFORE INSERT on `Centro_Medico`.TipoServicios
		FOR EACH ROW
		BEGIN
			set NEW.tipo := UPPER(NEW.tipo);
		END//
		DELIMITER ;
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

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Clientes`
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Patalogia`
-- -----------------------------------------------------
DELIMITER //
CREATE TRIGGER `TRIGGER_Patologias_BI_toUpper` BEFORE INSERT on `Centro_Medico`.Patologias
FOR EACH ROW
BEGIN
	set NEW.nombre := UPPER(NEW.nombre);
	set NEW.dniCliente := UPPER(NEW.dniCliente);
END//
DELIMITER ;

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleados`
-- -----------------------------------------------------
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
		-- -----------------------------------------------------
		-- Table `Centro_Medico`.`EmpleadoSecretario`
		-- -----------------------------------------------------
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
        -- -----------------------------------------------------
		-- Table `Centro_Medico`.`EmpleadoMedico`
		-- -----------------------------------------------------
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
		-- -----------------------------------------------------
		-- Table `Centro_Medico`.`EmpleadoPsicologo`
		-- -----------------------------------------------------
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
        -- -----------------------------------------------------
		-- Table `Centro_Medico`.`EmpleadoAdministrador`
		-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Cliente_Compra_Servicios_AtravesDe_Empleados`
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleado_Trabaja_Centro`
-- -----------------------------------------------------
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

-- El administrador a la hora de computar salarios, ejecutaría esta llamada:
-- SELECT 'El salario sería',calcSalary('12345678Z');




