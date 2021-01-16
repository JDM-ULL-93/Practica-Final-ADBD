DROP TABLE IF EXISTS `Centro_Medico`.Flags;
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Flags(
			`varName` VARCHAR(255) NOT NULL,
			`value` BOOLEAN NOT NULL DEFAULT FALSE,
			PRIMARY KEY (`varName`),
			UNIQUE INDEX `varName_UNIQUE` (`varName` ASC)
		);
/*
insert into 
	`Centro_Medico`.Flags(`varName`,`value`) 
VALUES 
	('EnableCheckMinPsicologoMedicoSecretario',1);
*/

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
 /* --  IMPRESCINDIBLES: Estas tablas actuan como un Enum
        insert into 
			`Centro_Medico`.ServiciosExternos(`tipo`) 
		VALUES 
			('Limpieza'),
			('Informática');
*/
        -- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`EmpresasExternas`
		-- -----------------------------------------------------
		CREATE TABLE IF NOT EXISTS `Centro_Medico`.EmpresasExternas(
			id INT NOT NULL AUTO_INCREMENT,
			empresa VARCHAR(55) NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `empresa_UNIQUE` (`empresa` ASC)
		);
        
CREATE TABLE IF NOT EXISTS `Centro_Medico`.AsistenciaExterior(/*Entidad : 'AsistenciaExterior'*/
	tipo INT NOT NULL/*ENUM ('Limpieza','Informática')*/,
    empresa INT NOT NULL/*VARCHAR(55)*/,
    PRIMARY KEY (`tipo`, `empresa`),
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

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Centro_Medico`.Centros(/*Entidad : 'Centro'*/
    direccion VARCHAR(255) NOT NULL,
    horarioInicio TIME NOT NULL,
    horarioFin TIME NOT NULL,
    PRIMARY KEY(`direccion`),
    UNIQUE INDEX `direccion_UNIQUE` (`direccion` ASC)
);

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
/* --  IMPRESCINDIBLES: Estas tablas actuan como un Enum
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
*/
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
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoSecretario`
	-- -----------------------------------------------------
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
	-- Table `Centro_Medico`.`EmpleadoMedico`
	-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- Auxiliar Table `Centro_Medico`.`MedicoEspecializacion`
		-- -----------------------------------------------------
		CREATE TABLE IF NOT EXISTS `Centro_Medico`.MedicoEspecializacion(
			id INT NOT NULL AUTO_INCREMENT,
			especializacion VARCHAR(70) NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `tipo_UNIQUE` (`especializacion` ASC)
		);
/* --  IMPRESCINDIBLES: Estas tablas actuan como un Enum       
		insert into 
			`Centro_Medico`.MedicoEspecializacion(`especializacion`)
		VALUES
			('Oftalmólogo'),
			('Dermatólogo'),
			('Cirujano Plástico');
 */           
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
    -- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoPsicologo`
	-- -----------------------------------------------------
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
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoAdministrador`
	-- -----------------------------------------------------  
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




