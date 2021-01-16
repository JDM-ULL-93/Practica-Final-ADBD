insert into 
	`Centro_Medico`.Flags(`varName`,`value`) 
VALUES 
	('EnableCheckMinPsicologoMedicoSecretario',1);

-- -----------------------------------------------------
-- Table `Centro_Medico`.`AsistenciaExterior`
-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`ServiciosExternos`
		-- -----------------------------------------------------
		insert into 
			`Centro_Medico`.ServiciosExternos(`tipo`) 
		VALUES 
			('Limpieza'),
			('Informática');
        -- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`EmpresasExternas`
		-- -----------------------------------------------------
		insert into 
			`Centro_Medico`.EmpresasExternas(`empresa`) 
		VALUES 
			("Limpiezas Paco"),
			("Informatica Matrix");
insert into 
	`Centro_Medico`.AsistenciaExterior(`tipo`,`empresa`) 
VALUES 
	(1, 1),
	(2, 2);
insert into `Centro_Medico`.AsistenciaExterior(`tipo`,`empresa`) VALUES (1, 2); -- Correcto

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros`
-- -----------------------------------------------------
insert into 
	`Centro_Medico`.Centros(`direccion`,`horarioInicio`,`horarioFin`) 
VALUES 
	('Dirección','08:00', '14:00');
 -- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros_Recibe_AsistenciaExterior`
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Table `Centro_Medico`.`Servicios`
-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`TipoServicios`
		-- -----------------------------------------------------
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
    
-- -----------------------------------------------------
-- Table `Centro_Medico`.`Clientes`
-- -----------------------------------------------------
insert into 
			`Centro_Medico`.Clientes(`nombre`,`dni`,`telefono`,`fechaNacimiento`)
		VALUES
			('Pedro','12345678Z','123456789',STR_TO_DATE('25-11-1993','%d-%m-%Y') ),
            ('Jose','87654321Z','987654321','1995-05-15');

/*ToDo : ¿Comprobar que el DNI introducido es correcto?*/

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Patalogia`
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleados`
-- -----------------------------------------------------
insert into 
	`Centro_Medico`.Empleados(`dni`,`fechaIni`,`fechaFin`)
VALUES
	('12345678Z',STR_TO_DATE('25-11-1993','%d-%m-%Y'),STR_TO_DATE('01-05-2025','%d-%m-%Y') ),
	('87654321Z','1995-05-15','2030-06-24'),
	('57614987G','2010-05-15','2025-04-13'),
	('47523978F','2018-05-15','2020-04-13');
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoSecretario`
	-- -----------------------------------------------------
    insert into 
		`Centro_Medico`.EmpleadoSecretario(`dniEmpleado`)
	VALUES
		('12345678Z');
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoMedico`
	-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- Auxiliar Table `Centro_Medico`.`MedicoEspecializacion`
		-- -----------------------------------------------------
		insert into 
			`Centro_Medico`.MedicoEspecializacion(`especializacion`)
		VALUES
			('Oftalmólogo'),
			('Dermatólogo'),
			('Cirujano Plástico');
	insert into 
		`Centro_Medico`.EmpleadoMedico(`dniEmpleado`,`especializacion`)
	VALUES
		('57614987G',1);
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoPsicologo`
	-- -----------------------------------------------------
	insert into 
		`Centro_Medico`.EmpleadoPsicologo(`dniEmpleado`)
	VALUES
		('87654321Z');
	

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Cliente_Compra_Servicios_AtravesDe_Empleados`
-- -----------------------------------------------------
insert into 
	`Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados
    (`dniEmpleado`,`dniCliente`,`direccionCentro`,`tipoServicio`,`fecha`,`fechaCad`)
VALUES
	('12345678Z','12345678Z','Dirección',1,STR_TO_DATE('14-01-2021','%d-%m-%Y'),'2025-01-14' ),
	('12345678Z','87654321Z','Dirección',4,STR_TO_DATE('14-01-2021','%d-%m-%Y'),'2025-01-14' );
-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleado_Trabaja_Centro`
-- -----------------------------------------------------
UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = FALSE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";
insert into 
	`Centro_Medico`.Empleado_Trabaja_Centro(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('12345678Z','DIRECCIÓN',1, NOW()),
	('57614987G','DIRECCIÓN',1, NOW()),
	('87654321Z','DIRECCIÓN',1, NOW());
UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = TRUE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";




