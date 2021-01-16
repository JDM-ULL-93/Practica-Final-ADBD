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

El check que se realiza dentro de esta fución puede desactivarse seteando la variable "<EnableCheckMinPsicologoMedicoSecretario>" de la taba "Flags" a FALSE.
Esta función es la responsable de comprobar en los triggers BeforeInsert, BeforeUpdate y BeforeDelete de la relación 'Trabaja', que el centro sobre el que se van a modificar sus 
registros cumple el minimo de 1 psicologo/a, 1 medico/a y 1 secretario/a
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

Ejecutado para obtener el atributo calculado 'salario/día' de la relación "Trabajo"
```sql
FUNCTION calcSalary (dniEmpleado CHAR(9));
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
FUNCTION isInOtherEmpleadoTable (dniEmpleado CHAR(9), excludeTable INT);
RETURNS BOOLEAN
```





