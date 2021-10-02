CREATE TABLE PERSONA(
	carnet char(7) NOT NULL,
	nombre varchar(35) NOT NULL,
	apellido char(40) NULL,
	sexo varchar(12) NULL,
	fecha_nac date,
	direccion varchar(30) NOT NULL,
	cel char(12) NULL,
	CONSTRAINT persona_pk PRIMARY KEY (carnet) 
)
INSERT PERSONA (carnet,nombre,apellido,sexo,fecha_nac,direccion,cel) 
VALUES ('7648723','DANIELA','ESCOBAR VINO','FEMENINO',CAST('1990-03-28' AS Date),'LOS PINOS','78596321')

/****			--------------------   USUARIO 	------------------------			***/ 
CREATE TABLE USUARIO(
	id_carnet char(7) NOT NULL,
	nom_usu varchar(10) NOT NULL,
	pasword varchar(7) NULL,
	CONSTRAINT usuario_pk PRIMARY KEY (id_carnet)
)
create proc reg_usuario
	@carnet char(7),@nombre varchar(35),@apellido varchar(40),@sexo varchar(12),@fecha_nac date,@direccion varchar(30),@cel char(12),
	@nom_usu varchar(10),@pswd varchar(7)
	as
	insert INTO PERSONA values (@carnet,@nombre,@apellido,@sexo,@fecha_nac,@direccion,@cel);
	insert into USUARIO(id_carnet,nom_usu,pasword)	values (@carnet,@nom_usu,@pswd)


exec reg_usuario '8977136','GISELA','1234'
exec reg_usuario '8320172','ROD','0000'

CREATE proc obt_dat_usu
@carnet int
as
select p.nombre,p.apellido,p.carnet,p.cel,u.nom_usu,u.pasword 
from PERSONA p ,USUARIO u	
where p.carnet=u.id_carnet and p.carnet = '8320172'/*@carnet*/
/****			--------------------   MEDICO 	------------------------			***/ 
create table MEDICO(
	id_medico char(7) NOT NULL,
	especialidad varchar(30) NOT NULL
	CONSTRAINT medico_pk PRIMARY KEY (id_medico)
)
create proc reg_medico
	@carnet char(7),@nombre varchar(35),@apellido varchar(40),@sexo varchar(12),@fecha_nac date,@direccion varchar(30),@cel char(12),@especialidad varchar(30)
	as
	insert PERSONA (carnet,nombre,apellido,sexo,fecha_nac,direccion,cel) 
	values (@carnet,@nombre,@apellido,@sexo,@fecha_nac,@direccion,@cel)
	insert MEDICO (id_medico,especialidad)	values (@carnet,@especialidad)

exec reg_medico '6951136','FLOR','QUISPE','FEMENINO','1985-06-12','VILLA FATIMA','71589632','FISIOTERAPIA EN TRAUMATOLOGIA'
exec reg_medico '8977136','GISELA','GUZMAN','FEMENINO','1990-06-20','AV BUENOS AIRES','74569852','FISIOTERAPIA EN NEUROLOGIA'
exec reg_medico '7648723','DANIELA','ESCOBAR VINO','FEMENINO','1990-03-28','LOS PINOS','78596321','FISIOTERAPIA EN PEDIATRIA'
create proc rep_medicos
	as
	select s.nombre,s.apellido,m.especialidad,s.cel,s.direccion,s.fecha_nac
	from PERSONA s,MEDICO m
	where m.id_medico = s.carnet
create proc carnet_med
	@nombre varchar(19)
	as
	select p.carnet
	from PERSONA p
	where p.nombre like @nombre
	
CREATE proc HC_medXnombre
	@nombre varchar(20)
	as
	declare @carnet varchar(8)=''
	set @carnet=(select m.id_medico from PERSONA p ,MEDICO m	
	where p.carnet=m.id_medico and p.nombre like @nombre )
	
	select c.fecha,s.nombre,s.apellido,o.reseta_med,o.pago
	from CITA c,PACIENTE p,PERSONA s,MEDICO m,CONSULTA o
	where m.id_medico = @carnet
	and o.cita=c.id_cita
	and c.id_paciente=p.id_paciente
	and p.id_paciente = s.carnet 
	and c.id_medico=m.id_medico

/****			--------------------   PACIENTE 	------------------------			***/ 
create table PACIENTE(
	id_paciente char(7) NOT NULL,
	seguro varchar(20) NOT NULL
	CONSTRAINT paciente_pk PRIMARY KEY (id_paciente)
)
create proc reg_paciente
	@carnet char(7),@nombre varchar(35),@apellido varchar(40),@sexo varchar(12),@fecha_nac date,@direccion varchar(30),@cel char(12),@seguro varchar(20)
	as
	insert PERSONA (carnet,nombre,apellido,sexo,fecha_nac,direccion,cel) 
	values (@carnet,@nombre,@apellido,@sexo,@fecha_nac,@direccion,@cel)
	insert PACIENTE (id_paciente,seguro)	values (@carnet,@seguro)

exec reg_paciente '4950236','MOISES','CHIPANA','MASCULINO','1990-11-02','ACHACHICALA','71234567','SI'
exec reg_paciente '5698742','GERARDO','LUNA','MASCULINO','2021-04-02','OBRAJES','75698750','NO'
exec reg_paciente '6987450','SANDRA','PEREZ','FEMENINO','2021-04-02','VILLA FATIMA','71589632','NO'
create proc rep_pacientes_espe
	as
	select distinct s.carnet,s.nombre,s.apellido,s.cel,p.seguro,m.especialidad
	from PACIENTE p,PERSONA s,CITA c,MEDICO m
	where s.carnet = p.id_paciente
	and c.estado like 'ATENDIDO'
	and p.id_paciente = c.id_paciente
	and m.id_medico = c.id_medico

exec rep_pacientes_espe
create proc rep_pacientes
	as
	select s.carnet,s.nombre,s.apellido,s.cel,p.seguro
	from PACIENTE p,PERSONA s
	where s.carnet = p.id_paciente

exec rep_pacientes
create proc reg_paciente
	@carnet char(7),@nombre varchar(35),@apellido varchar(40),@sexo varchar(12),@fecha_nac date,@direccion varchar(30),@cel char(12),@seguro varchar(20)
	as
	insert PERSONA (carnet,nombre,apellido,sexo,fecha_nac,direccion,cel) 
	values (@carnet,@nombre,@apellido,@sexo,@fecha_nac,@direccion,@cel)
	insert PACIENTE (id_paciente,seguro)	values (@carnet,@seguro)

/****			--------------------   CITA 	------------------------			***/ 
create table CITA(
	id_cita INT identity(1,1) NOT NULL,
	asunto varchar(30) not null,
	fecha date not null,
	estado varchar(15) not null,
	id_medico char(7) not null,
	id_paciente char(7) not null,
	constraint cita_pk primary key (id_cita),
	constraint cita_fk_med foreign key (id_medico) references MEDICO(id_medico),
	constraint cita_fk_pac foreign key (id_paciente) references PACIENTE(id_paciente)
 )
create proc reg_cita_nuevo
	@carnet char(7),@nombre varchar(35),@apellido varchar(40),@sexo varchar(12),@fecha_nac date,@direccion varchar(30),@cel char(12),@seguro varchar(20),
	@medico char(7),
	@asunto varchar(30),@fecha date,@estado varchar(15)
	as
	exec reg_paciente @carnet,@nombre,@apellido,@sexo,@fecha_nac,@direccion,@cel,@seguro
	insert into CITA values (@asunto,@fecha,@estado,@medico,@carnet)

	exec reg_cita_nuevo '9895961','ROGELIO','CHURA','MASCULINO','2005-11-30','C.SATELITE','7766558844','SI',
	'6951136','RECUPERACION DE FRACTURA','2021-07-30','RESERVADO'
create proc reg_cita_antiguo
	@carnet char(7),
	@medico char(7),
	@asunto varchar(30),@fecha date,@estado varchar(15)
	as
	insert into CITA values (@asunto,@fecha,@estado,@medico,@carnet)

	exec reg_cita_antiguo '9895961','6951136','RECUPERACION DE FRACTURA','2021-08-06','RESERVADO'
create proc rep_citas
	as
	select c.fecha,c.estado,s.nombre,s.apellido,m.especialidad,c.asunto
	from CITA c,PACIENTE p,PERSONA s,MEDICO m
	where c.id_paciente=p.id_paciente
	and p.id_paciente = s.carnet 
	and c.id_medico=m.id_medico

/****			--------------------   CONSULTA 	------------------------			***/ 
create table CONSULTA(
	id_consulta int identity(1,1) NOT NULL,
	cita int not null,
	pago int not null,
	obs varchar(30) null,
	reseta_med varchar(50) null,
	constraint consulta_pk primary key (id_consulta),
	constraint consulta_fk_cita foreign key (cita) references CITA(id_cita)  
)
create proc reg_consulta_antiguo
	@cita int,
	@pago int,@obs varchar(30),@reseta_med varchar(50)
	as
	insert into CONSULTA values (@cita,@pago,@obs,@reseta_med)

	exec reg_consulta_antiguo '1','200','Primera sesion de trabajo','NINGUNA'
create proc reg_consulta_nuevo
	@carnet char(7),@nombre varchar(35),@apellido varchar(40),@sexo varchar(12),@fecha_nac date,@direccion varchar(30),@cel char(12),@seguro varchar(20),
	@medico char(7),
	@asunto varchar(30),@fecha date,
	@pago int,@obs varchar(30),@reseta_med varchar(50)
	as
	exec reg_cita_nuevo @carnet,@nombre,@apellido,@sexo,@fecha_nac,@direccion,@cel,@seguro,
	@medico,@asunto,@fecha,'ATENDIDO'
	declare @ultimo int = 0;
	set @ultimo = (SELECT max(c.id_cita) FROM CITA c)
	insert into CONSULTA values (@ultimo,@pago,@obs,@reseta_med)

exec reg_consulta_nuevo '9893547','MARCELA','LIMACHI','FEMENINO','2000-01-03','OBRAJES','69665588','SI',
'6951136','DESGARRE DE TENDON DE AQUILES','2021-07-30','250','Para dar de Alta','NINGUNA'
exec reg_consulta_nuevo '8593547','RICHARD','COAQUIRA','MASCULINO','2000-06-05','OVEJUYO','70667588','NO',
'8977136','desgarre muscular del brazo derecho','2021-07-02','200','Vino por primera vez','ANALGESICO'
        //9893547   8593547
        //9895961   8893767


create proc rep_pago_Xfye
	@fecha date,
	@espe varchar(30)
	as
	select o.pago,s.nombre,s.apellido,c.id_paciente,c.fecha,m.especialidad
	from CITA c,CONSULTA o,PACIENTE p,PERSONA s,MEDICO m
	where c.fecha like @fecha
	and m.especialidad like @espe
	and o.cita = c.id_cita
	and p.id_paciente = c.id_paciente
	and s.carnet = p.id_paciente
	and c.id_medico = m.id_medico

exec rep_pago_Xfye '2021-07-30','FISIOTERAPIA EN TRAUMATOLOGIA'
exec rep_pago_Xfye '2021-08-02','FISIOTERAPIA EN NEUROLOGIA'

create proc rep_pago_Xfecha
	@fecha date
	as
	select o.pago,s.nombre,s.apellido,c.id_paciente,c.fecha,m.especialidad
	from CITA c,CONSULTA o,PACIENTE p,PERSONA s,MEDICO m
	where c.fecha like @fecha
	and o.cita = c.id_cita
	and p.id_paciente = c.id_paciente
	and s.carnet = p.id_paciente
	and c.id_medico = m.id_medico
exec rep_pago_Xfecha'2021-07-30'

CREATE proc rep_consultas
	as
	select c.fecha,o.pago,m.especialidad,s.nombre,s.apellido,o.reseta_med
	from CITA c,PACIENTE p,PERSONA s,MEDICO m,CONSULTA o
	where o.cita=c.id_cita
	and c.id_paciente=p.id_paciente
	and p.id_paciente = s.carnet 
	and c.id_medico=m.id_medico

/**		__________ ´PROCEDIMIENTO ALMACENADO: EXTRAE EL ID_CITA ULTIMO ________________**/
CREATE proc reg_cita_nuevo
	@carnet char(8),
	@medico char(8),
	@asunto varchar(30),@fecha date,@estado varchar(15)
	as
	insert into CITA values (@asunto,@fecha,@estado,@medico,@carnet)
CREATE proc reg_consulta_nuevo
	@pago int,@obs varchar(30),@reseta_med varchar(50)
	as
	declare @ultimo int = 0;
	set @ultimo = (SELECT max(c.id_cita) FROM CITA c)
	insert into CONSULTA values (@ultimo,@pago,@obs,@reseta_med)

create table ANTECEDENTES(
	id_paciente varchar(8) primary key not null,
	peso real not null,
	talla real not null,
	ref_dm varchar(50) not null,
	antes varchar(9) not null
)

create proc variable
	as
	declare @ultimo int = 0; set @ultimo = (SELECT max(c.id_cita) FROM CITA c)
	print @ultimo
exec variable

Excepción no controlada del tipo 'System.Data.SqlClient.SqlException' en System.Data.dll

Información adicional: Violation of PRIMARY KEY constraint 'persona_pk'. 
Cannot insert duplicate key in object 'dbo.PERSONA'. 
The duplicate key value is (*       ).


SELECT DISTINCT s.carnet, s.nombre, s.apellido, s.cel, p.seguro, m.especialidad
FROM            PACIENTE AS p INNER JOIN
                         PERSONA AS s ON p.id_paciente = s.carnet INNER JOIN
                         CITA AS c ON p.id_paciente = c.id_paciente INNER JOIN
                         MEDICO AS m ON c.id_medico = m.id_medico
WHERE        (c.estado LIKE 'ATENDIDO')

create table HORARIO(id_hora varchar(2) primary key,hora time(0) )




select distinct c.id_paciente,r.nombre,r.apellido,r.fecha_nac 
from CITA c, CONSULTA s, PACIENTE p, PERSONA r 
where c.id_cita = s.cita and c.id_paciente=p.id_paciente 
and p.id_paciente=r.carnet 
ORDER BY c.id_paciente



create proc reg_cita_antiguo
	@carnet char(8),
	@medico char(8),
	@asunto varchar(30),@fecha date,@estado varchar(15)
	as
	insert into CITA values (@asunto,@fecha,@estado,@medico,@carnet)

select * from CITA
exec reg_cita_antiguo '12800449','6951136','RECUPERACION DE FRACTURA','2021-08-06','RESERVADO'

/*create proc lista_horarios
as
select c.id_cita,c.fecha,c.hora, h.id_hora,h.ocupado from CITA c, HORARIO h where h.hora=c.hora and c.fecha like'2021-08-20'

select c.id_cita,c.fecha,c.hora from CITA c where fecha like'2021-08-20'
	update HORARIO set ocupado = '1' WHERE hora = '8:30' 

select * from HORARIO
exec reg_cita_antiguo '12800449','6951136','RECUPERACION DE FRACTURA','2021-08-06','RESERVADO','8:30'

select p.nombre from PERSONA p, MEDICO m where m.id_medico=p.carnet
select * from CITA

create proc lista_horarios
	@fecha date
	as
	select h.hora from HORARIO h where hora NOT IN
	(select c.hora from CITA c where c.fecha like @fecha)

exec lista_horarios '2021-08-19'
select c.hora from CITA c where c.fecha like '2021-08-19'
select c.id_cita,c.fecha,c.hora from CITA c*/