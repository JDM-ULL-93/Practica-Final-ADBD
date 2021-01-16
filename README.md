# PROYECTO
## Centro‌ ‌Médico‌ ‌del‌ ‌Coche‌ 
### Autores
Florentín‌ ‌Pérez‌ ‌González‌ 	( ‌alu0101100654@ull.edu.es )

Javier‌ ‌Duque‌ ‌Melguizo‌ 		‌( ‌alu0101160337‌‌@ull.edu.es )

‌Eduardo‌ ‌Suárez‌ ‌Ojeda‌ ‌		‌( ‌alu0100896565‌‌‌@ull.edu.es )
 
### Documentación


```sql
FUNCTION getCosteBaseServicio(tipoServicio INT,direccionCentro VARCHAR(255));
RETURNS FLOAT
```

```sql
FUNCTION getSumPenalizacionPatalogiasCliente (dniCliente CHAR(9));
RETURNS FLOAT
```

```sql
FUNCTION getEdadCliente (dniCliente CHAR(9));
RETURNS FLOAT
```

```sql
FUNCTION getEdadCliente (dniCliente CHAR(9));
RETURNS FLOAT
```

```sql
FUNCTION thereIsMinPsicologoMedicoSecretario (direccion VARCHAR(255));
RETURNS BOOLEAN
```

```sql
FUNCTION IsEmpleadoSecretario (dniEmpleado CHAR(9));
RETURNS BOOLEAN
```

```sql
FUNCTION IsEmpleadoMedico (dniEmpleado CHAR(9));
RETURNS BOOLEAN
```

```sql
FUNCTION IsEmpleadoPsicologo (dniEmpleado CHAR(9));
RETURNS BOOLEAN
```

```sql
FUNCTION IsEmpleadoAdministrador (dniEmpleado CHAR(9));
RETURNS BOOLEAN
```

```sql
FUNCTION calcSalary (dniEmpleado CHAR(9))
RETURNS FLOAT
```


```sql
/*
excludeTable{
	1 = PSICOLOGO,
    2 = MEDICO,
    3 = SECRETARIO
    4 = ADMINISTRADOR
}
*
FUNCTION isInOtherEmpleadoTable (dniEmpleado CHAR(9), excludeTable INT)
RETURNS BOOLEAN
```





