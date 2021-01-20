# PROYECTO
## Centro‌ ‌Médico‌ ‌del‌ ‌Coche‌ 
### Autores
Florentín‌ ‌Pérez‌ ‌González‌ 	( ‌alu0101100654@ull.edu.es )

Javier‌ ‌Duque‌ ‌Melguizo‌ 		‌( ‌alu0101160337‌‌@ull.edu.es )

‌Eduardo‌ ‌Suárez‌ ‌Ojeda‌ ‌		‌( ‌alu0100896565‌‌‌@ull.edu.es )
 
 
# Descripción:

El Centro Médico del Coche es una empresa que se dedica a ofrecer certificados médicos en Tenerife con una máxima profesionalidad y un trato excelente. Se proporcionan servicios de carner de conducir, certificados médicos, renovación del carnet, canjes, certificados para seguridad privada, certificados de armas, certificados de perror peligrosos, de buceo... etc.

Dicha empresa cuenta con tres centros en la isla de Tenerife, localizados en la zona norte de la isla, en concreto en los municipios de La Orotava, Icod de los Vinos y Los Realejos. Cada centro tiene un horario fijo para los días laborables.

Actualmente la empresa cuenta con una plantilla de empleados que se dividen en médicos, psicólogos, secretarios y administradores. Dichos empleados rotan entre los distintos centros manteniendo en todo momento la couta mínima de miembros necesaria que se puedan expedir todos los tipos de ceertificados disponibles en los centros, en concreto la plantilla mínima constará de 1 médico, 1 psicólogo y 1 secretario.

Por otro lado los clientes acuden para solicitar un certificado especifico. Pueden obtener una cita previa o acceder al centro sin ella. El coste y la duración de los certificados varían en función de la edad y de las patologías que sufra dicho cliente. 

A la empresa le interesa guardar la información necesaria sobre sus clientes para recordarle cuando la fecha de expiración se aproxime y ofrecerles una nueva cita para renovar el certificado. Paara ello es necesario guardar, tanto la fecha de expiración de los diversos ceertificados como los números de teléfono de los clientes, o en su defecto, su correo electrónico.
 
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

*thereIsMinPsicologoMedicoSecretario* : El check que se realiza dentro de esta fución puede desactivarse seteando la variable "<EnableCheckMinPsicologoMedicoSecretario>" de la taba "Flags" a FALSE.
Esta función es la responsable de comprobar en los triggers BeforeInsert, BeforeUpdate y BeforeDelete de la relación 'Trabaja', que el centro sobre el que se van a modificar sus 
registros cumple el minimo de 1 psicologo/a, 1 medico/a y 1 secretario/a

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
FUNCTION calcSalary (dniEmpleado CHAR(9));
RETURNS FLOAT
```
*calcSalary* : Ejecutado para obtener el atributo calculado 'salario/día' de la relación "Trabajo"


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
*isInOtherEmpleadoTable* : Administra la restricción de exclusividad. Responsable de que 1 empleado solo pueda ser o Medico, o Administrador, o Secretario, o Psicologo.


