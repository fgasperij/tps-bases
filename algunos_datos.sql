insert into Modalidad values ("Combate");
insert into Modalidad values ("Combate por equipos");
insert into Modalidad values ("Rotura de potencia");
insert into Modalidad values ("Formas");
insert into Modalidad values ("Salto");

-- (IDCategoria, Graduacion, EdadMinima, EdadMaxima, Sexo, PesoMinimo, PesoMaximo)
-- Rotura de potencia, Salto y Combate por equipos
insert into Categoria values (1, null, 14, 17, "M", null, null);
insert into Categoria values (2, null, 18, 35, "M", null, null);
insert into Categoria values (3, null, 14, 17, "F", null, null);
insert into Categoria values (4, null, 18, 35, "F", null, null);
-- Formas
insert into Categoria
	select null, Graduacion.Graduacion, EdadMinima, EdadMaxima, Sexo, null, null
  from Categoria
  cross join (
    select 1 as Graduacion
    union all select 2 as Graduacion
    union all select 3 as Graduacion
    union all select 4 as Graduacion
    union all select 5 as Graduacion
    union all select 6 as Graduacion
  ) Graduacion;
-- Combate
insert into Categoria
	select null, Graduacion, EdadMinima, EdadMaxima, Sexo, Peso.PesoMinimo, Peso.PesoMaximo
  from Categoria
  cross join (
    select 54 as PesoMinimo, 58 as PesoMaximo
    union all select 58 as PesoMinimo, 63 as PesoMaximo
    union all select 63 as PesoMinimo, 68 as PesoMaximo
    union all select 68 as PesoMinimo, 74 as PesoMaximo
    union all select 74 as PesoMinimo, 80 as PesoMaximo
    union all select 80 as PesoMinimo, 87 as PesoMaximo
    union all select 87 as PesoMinimo, null as PesoMaximo
  ) Peso
  where Categoria.Graduacion is not null;

-- (IDCategoria, NombreModalidad, Ring)
-- Combate por equipos, Salto y Rotura de potencia
insert into SeDivideEn
  select Categoria.IDCategoria, Modalidad.NombreModalidad, floor(rand()*10)+1
  from (
  	select *
  	from Categoria
  	where Categoria.Graduacion is null and Categoria.PesoMinimo is null and Categoria.PesoMaximo is null
  ) Categoria
  cross join (
    select NombreModalidad
    from Modalidad
    where NombreModalidad = "Combate por equipos" or NombreModalidad = "Salto" or NombreModalidad = "Rotura de potencia"
  ) Modalidad;
-- Formas
insert into SeDivideEn
  select Categoria.IDCategoria, "Formas", floor(rand()*10)+1
  from Categoria
  where Categoria.Graduacion is not null and Categoria.PesoMinimo is null and Categoria.PesoMaximo is null;
-- Combate
insert into SeDivideEn
  select Categoria.IDCategoria, "Combate", floor(rand()*10)+1
  from Categoria
  where Categoria.Graduacion is not null and Categoria.PesoMinimo is not null and Categoria.PesoMaximo is not null;

insert into Pais values("Sealand");

-- (PlacaInstructor, Escuela, NombreCompleto, Graduacion, NombrePais)
insert into Maestro values(1, "Escuela 1", "Maestro", 1, "Sealand");

-- (NumeroCertificadoGraduacion, Foto, Graduacion, NombreCompleto, PlacaInstructor)
insert into Registrado values(1, null, 1, "A A", 1);
insert into Registrado values(2, null, 2, "B B", 1);
insert into Registrado values(3, null, 3, "C C", 1);
insert into Registrado values(4, null, 4, "D D", 1);
insert into Registrado values(5, null, 5, "E E", 1);
insert into Registrado values(6, null, 6, "F F", 1);
insert into Registrado values(7, null, 1, "G G", 1);
insert into Registrado values(8, null, 1, "H H", 1);

-- (NumeroCertificadoGraduacion, Peso, DNI, FechaNacimiento, Sexo, RolEquipo, NombreEquipo)
insert into Competidor values (1, 60, 12345678, "1994-05-06", "M", null, null);
insert into Competidor values (2, 70, 12345678, "1994-05-06", "M", null, null);
insert into Competidor values (3, 80, 12345678, "1994-05-06", "M", null, null);
insert into Competidor values (4, 90, 12345678, "1994-05-06", "M", null, null);
insert into Competidor values (5, 60, 12345678, "1994-05-06", "M", null, null);

-- (NumeroCertificadoGraduacion, NombreModalidad)
insert into Inscripto values (1, "Combate");
insert into Inscripto values (2, "Combate");
insert into Inscripto values (3, "Combate");
insert into Inscripto values (1, "Formas");
insert into Inscripto values (2, "Formas");
insert into Inscripto values (3, "Formas");
insert into Inscripto values (4, "Formas");

-- (NumeroCertificadoGraduacion)
insert into Coach values (8);

-- (IDParticipacion, Resultado, IDCategoria, NombreModalidad, NumeroCertificadoGraduacionCoach)
insert into Participacion values(1, 1, 7, "Formas", 8, "Individual");
insert into Participacion values(2, 2, 7, "Formas", 8, "Individual");
insert into Participacion values(3, 3, 7, "Formas", 8, "Individual");

-- (IDParticipacion, NumeroCertificadoGraduacion)
insert into ParticipacionIndividual values(1, 1);
insert into ParticipacionIndividual values(2, 2);
insert into ParticipacionIndividual values(3, 3);

