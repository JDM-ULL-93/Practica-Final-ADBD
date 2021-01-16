/* CHECK TABLE INSERTS*/
select * from `Centro_Medico`.Flags;

/*CHECK FUNCTIONS WORKING AS INTENDED*/
select getCosteBaseServicio(1,"DIRECCIÓN");
select getSumPenalizacionPatalogiasCliente("12345678Z");
select getEdadCliente("12345678Z");
select calcCoste("12345678Z",1,"DIRECCIÓN",NOW(),DATE_ADD(NOW(),interval 1 year ) );
select thereIsMinPsicologoMedicoSecretario("DIRECCIÓN"); -- TRUE
select IsEmpleadoSecretario("12345678Z"); -- TRUE
select IsEmpleadoMedico("12345678Z"); -- FALSE
select IsEmpleadoPsicologo("12345678Z"); -- FALSE
select IsEmpleadoAdministrador("12345678Z"); -- FALSE
select calcSalary("12345678Z");
/*
excludeTable{
	1 = PSICOLOGO,
    2 = MEDICO,
    3 = SECRETARIO
    4 = ADMINISTRADOR
}
*/
select isInOtherEmpleadoTable("12345678Z",1); -- TRUE

-- -----------------------------------------------------
-- Table `Centro_Medico`.`AsistenciaExterior`
-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`ServiciosExternos`
		-- -----------------------------------------------------
        select id, tipo from `Centro_Medico`.ServiciosExternos;
        -- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`EmpresasExternas`
		-- -----------------------------------------------------
        select id,empresa from `Centro_Medico`.EmpresasExternas;
        
select `SE`.tipo,`EE`.empresa from `Centro_Medico`.AsistenciaExterior as `AE` 
    inner join `Centro_Medico`.ServiciosExternos as `SE` on `AE`.tipo = `SE`.id
    inner join `Centro_Medico`.EmpresasExternas as `EE` on `AE`.empresa = `EE`.id;

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros`
-- -----------------------------------------------------
select * from `Centro_Medico`.Centros;

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Centros_Recibe_AsistenciaExterior`
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Servicios`
-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- AUXILIAR TABLE `Centro_Medico`.`TipoServicios`
		-- -----------------------------------------------------
        select * from `Centro_Medico`.TipoServicios;

select direccionCentro,TS.tipo,`%administrador`,`%secretario`,`%psicologo`,`%medico` 
from `Centro_Medico`.Servicios as S 
inner join TipoServicios as TS on TS.id = S.tipo ;


-- -----------------------------------------------------
-- Table `Centro_Medico`.`Clientes`
-- -----------------------------------------------------
select * from `Centro_Medico`.Clientes;

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Patalogia`
-- -----------------------------------------------------
select * from `Centro_Medico`.Patologias;

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleados`
-- -----------------------------------------------------
select * from `Centro_Medico`.Empleados;
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoSecretario`
	-- -----------------------------------------------------
	select * from `Centro_Medico`.EmpleadoSecretario;
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoMedico`
	-- -----------------------------------------------------
		-- -----------------------------------------------------
		-- Auxiliar Table `Centro_Medico`.`MedicoEspecializacion`
		-- -----------------------------------------------------
        select * from `Centro_Medico`.`MedicoEspecializacion`;
	select * from `Centro_Medico`.EmpleadoMedico;
    
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoPsicologo`
	-- -----------------------------------------------------
    select * from `Centro_Medico`.EmpleadoPsicologo;
    
	-- -----------------------------------------------------
	-- Table `Centro_Medico`.`EmpleadoAdministrador`
	-- -----------------------------------------------------
    select * from `Centro_Medico`.EmpleadoAdministrador;

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Cliente_Compra_Servicios_AtravesDe_Empleados`
-- -----------------------------------------------------
select * from `Centro_Medico`.`Cliente_Compra_Servicios_AtravesDe_Empleados`;

-- -----------------------------------------------------
-- Table `Centro_Medico`.`Empleado_Trabaja_Centro`
-- -----------------------------------------------------
select * from `Centro_Medico`.`Empleado_Trabaja_Centro`;


-- _____________________________________________________________________________________
-- ____________________________PRUEBA DE LAS RESTRICCIONES______________________________
-- _____________________________________________________________________________________
-- “En la entidad Centro, `HorarioFin` no puede ser anterior que `HorarioInicio`”
-- Se prueba el siguiente “insert” con un `horarioFin` anterior al `horarioInicio`
insert into `Centro_Medico`.Centros(`direccion`,`horarioInicio`,`horarioFin`) 
VALUES 
('Dirección2','14:00', '08:00');
-- Ocurre un error que impide la inserción:
-- La restricción añadida en el trigger `TRIGGER_Centros_BI_toUpperDireccion_And_hInicio_lt_hFin` funciona.
-- _____________________________________________________________________________________
-- “El sumatorio de porcentajes en la tabla `Servicios` debe ser 1”
-- Añadimos un nuevo centro para testear:
insert into 
	`Centro_Medico`.Centros(`direccion`,`horarioInicio`,`horarioFin`) 
VALUES 
	('Dirección2','10:00', '17:00');
-- Probamos:
insert into `Centro_Medico`.Servicios
(`direccionCentro`,`tipo`,`precioBase`,`%administrador`,`%secretario`,`%psicologo`,`%medico`)
VALUES
('Dirección2',1,665,0,0.25,0.25,0.25);
-- Ocurre un error en la inserción:

-- “Los empleados solo pueden ser una cosa, o secretario, o medico, o psicologo, o administrador”
-- El empleado con DNI ‘87654321Z’ ya existe en la tabla ‘EmpleadoPsicologo’. Si intentamos añadirlo a la tabla ‘EmpleadoSecretario’:
insert into 
	`Centro_Medico`.EmpleadoSecretario(`dniEmpleado`)
VALUES
	('87654321Z');
-- Ocurre un error en la inserción:
-- _____________________________________________________________________________________
-- El valor asignado al campo ‘fecha’ es menor que el valor asignado al campo ‘fechaCad’ en la relación ‘Trabaja’
-- Si intentamos insertar una fila que incumpla esa restricción:
insert into 
	`Centro_Medico`.Cliente_Compra_Servicios_AtravesDe_Empleados  (`dniEmpleado`,`dniCliente`,`direccionCentro`,`tipoServicio`,`fecha`,`fechaCad`)
VALUES
('87654321Z','87654321Z','Dirección2',1,'2025-01-14',STR_TO_DATE('14-01-2021','%d-%m-%Y') );
-- Ocurre un error en la inserción:

-- _____________________________________________________________________________________
-- Dentro de la relación de Empleado_Trabaja_Centro se debe cumplir que cada centro en cada día laborable tenga al menos un empleado de cada tipo: psicólogos, secretarios y médicos.
-- Para la prueba sobre centro 'Dirección2' primero deberemos rellenar la tabla 'Servicios' sobre la cual reside la restricción Foreign Key:
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
-- Si intentamos insertar una fila en relación al nuevo centro insertado anteriormente:
insert into 
	`Centro_Medico`.Empleado_Trabaja_Centro
	(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('47523978F','DIRECCIÓN2',2, NOW());
-- Ocurre un  error en la inserción advirtiendonos de que primero hay que solucionar la falta de personal desactivando un flag para permitir la inserción en la relación:
select * from Empleado_Trabaja_Centro;
-- SET autocommit = 0;
-- START TRANSACTION;
-- Lo anterior se soluciona desactivando el flag ‘EnableCheckMinPsicologoMedicoSecretario’ que se encuentra en la tabla ‘Flags’:
UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = FALSE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";
-- Insertando 3 empleados, cumpliendo que cada uno seá psicologo, medico o secretario:
insert into 	
	`Centro_Medico`.Empleado_Trabaja_Centro
	(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('12345678Z','DIRECCIÓN2',1, NOW()),
	('57614987G','DIRECCIÓN2',1, NOW()),
	('87654321Z','DIRECCIÓN2',1, NOW());
-- Recordamos re-activar el flag para futuras comprobaciones:
UPDATE `Centro_Medico`.Flags SET `Centro_Medico`.Flags.`value` = TRUE WHERE `Centro_Medico`.Flags.varName = "EnableCheckMinPsicologoMedicoSecretario";
-- Si volvemos a intentar insertar la fila que inicialmente nos prohibió, esta vez tendremos éxito en la acción:  
insert into 
	`Centro_Medico`.Empleado_Trabaja_Centro
	(`dniEmpleado`,`direccionCentro`,`tipoServicio`,`fecha`)
VALUES
	('47523978F','DIRECCIÓN2',2, NOW());
-- COMMIT;
-- SET autocommit = 1;

-- ________________________________________________________________________
-- En la entidad Empleados, FechaFin no puede ser anterior que FechaIni
-- Si intentamos saltar esa restricción:
insert into 
	`Centro_Medico`.Empleados(`dni`,`fechaIni`,`fechaFin`)
VALUES
('12345678Z',STR_TO_DATE('25-11-1993','%d-%m-%Y'),STR_TO_DATE('01-05-1992','%d-%m-%Y') );
-- Ocurre un error en la inserción.



