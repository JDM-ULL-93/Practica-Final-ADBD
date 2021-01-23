# PROYECTO
## Centro‌ ‌Médico‌ ‌del‌ ‌Coche‌ 
### Autores
Florentín‌ ‌Pérez‌ ‌González‌ 	( ‌alu0101100654@ull.edu.es )

Javier‌ ‌Duque‌ ‌Melguizo‌ 		‌( ‌alu0101160337‌‌@ull.edu.es )

‌Eduardo‌ ‌Suárez‌ ‌Ojeda‌ ‌		‌( ‌alu0100896565‌‌‌@ull.edu.es )
 
# Enlaces a documentos
Para acceder a los siguientes enlaces es necesario acceder con una cuenta miembro de la ULL. No obstante, todos los contenidos de dichos enlaces se encuentran de igual manera en el repositorio GitHub en el que se aloja este documento.
 - [Modelo ER/E](https://docs.google.com/document/d/1iL50QSurMU7_aJ1vxwGYh19y7CYXFcFbAihCBNmKgq0/edit?usp=sharing)
 - [Modelo lógico relacional](https://drive.google.com/file/d/14t0jT_w1wrEIex01eqJ8og53wtkqIAL4/view?usp=sharing)
 - [Generación de código](https://docs.google.com/document/d/1XHEIomJ6qs3NBY01AfZHOMPMvjUaCd6DL4S51O_HZLU/edit?usp=sharing)
 - [Carga de datos](https://docs.google.com/document/d/1S4d5J_7XqTSasfPNj1kCIfsQ8GkMeAQp-brxX9Rvikc/edit?usp=sharing)
 - [Scripts](https://drive.google.com/drive/folders/1vpq5KUp80rZm5kahULCwD3Up39N0DC80?usp=sharing)
# Descripción general:
El presente documento se trata de un informe básico sobre el proyecto final de ADBD. Este consistía en la creación desde cero de una base de datos para una organización. Para ello era necesario proceder con una recopilación inicial de requisitos y, posteriormente, representarlos bajo los estándares de los modelos ER/E y lógico relacional. Acto seguido, los modelos obtenidos se usaban como base para la creación de los scripts MySQL correspondientes que permitiesen la codificación de la base de datos, además de cualquier posible disparador que se considerase necesario para mantener la integridad y coherencia de los datos una vez la base de datos comenzara su funcionamiento.

# Descripción - Requisitos:

El Centro Médico del Coche es una empresa que se dedica a ofrecer certificados médicos en Tenerife con una máxima profesionalidad y un trato excelente. Se proporcionan servicios de carner de conducir, certificados médicos, renovación del carnet, canjes, certificados para seguridad privada, certificados de armas, certificados de perror peligrosos, de buceo... etc.

Dicha empresa cuenta con tres centros en la isla de Tenerife, localizados en la zona norte de la isla, en concreto en los municipios de La Orotava, Icod de los Vinos y Los Realejos. Cada centro tiene un horario fijo para los días laborables.

Actualmente la empresa cuenta con una plantilla de empleados que se dividen en médicos, psicólogos, secretarios y administradores. Dichos empleados rotan entre los distintos centros manteniendo en todo momento la couta mínima de miembros necesaria que se puedan expedir todos los tipos de ceertificados disponibles en los centros, en concreto la plantilla mínima constará de 1 médico, 1 psicólogo y 1 secretario.

Por otro lado los clientes acuden para solicitar un certificado especifico. Pueden obtener una cita previa o acceder al centro sin ella. El coste y la duración de los certificados varían en función de la edad y de las patologías que sufra dicho cliente. 

A la empresa le interesa guardar la información necesaria sobre sus clientes para recordarle cuando la fecha de expiración se aproxime y ofrecerles una nueva cita para renovar el certificado. Paara ello es necesario guardar, tanto la fecha de expiración de los diversos ceertificados como los números de teléfono de los clientes, o en su defecto, su correo electrónico.
 
# Distribución de tareas:
### Común:
- Recopilación de requisitos.
- Modelo ER/E.
- Redacción de documentos (Tanto este como los propios de cada sección del proyecto).
- Modelo lógico relacional.
### Javier Duque Melguizo:
- Construcción de la base de datos en MySQL.
### Florentín Pérez González y Eduardo Suarez Ojeda.
- Triggers e implementaciones de restricciones semánticas.
- Realización de pruebas y corrección de errores.

# Reuniones realizadas.
### 7 de diciembre de 2020:
- Recopilación conjunta de requisitos.
### 12 de diciembre de 2020:
- Creación conjunta del modelo ER/E.
### 29 de diciembre de 2020:
- Distribución de tareas y comienzo de la construcción de la BBDD en MySQL.
### 3 de enero de 2021:
-  Reunión de evaluación sobre el trabajo realizado y planificación de los documentos.
### 19 de enero de 2021:
- Finalización del proyecto. Planificación de los documentos finales.

 
### Documentación
A continuación se mostrarán algunas funciones ideadas para ser utilizadas por el personal administrador. Estas funciones están dirigidas a ser ejecutadas en momentos concretos bajo ciertos intereses por parte de la empresa. Por ejemplo, podrían utilizarse para comprobar información de los clientes y/o trabajadores.

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

*thereIsMinPsicologoMedicoSecretario* : La comporbación que se realiza dentro de esta fución puede desactivarse fijando la variable "<EnableCheckMinPsicologoMedicoSecretario>" de la taba "Flags" a FALSE.
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


