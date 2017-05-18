insert into Modalidad values ("Combate");
insert into Modalidad values ("Combate por Equipos");
insert into Modalidad values ("Rotura de potencia");
insert into Modalidad values ("Formas");
insert into Modalidad values ("Salto");

-- (IDCategoria, Graduacion, EdadMinima, EdadMaxima, Sexo, PesoMinimo, PesoMaximo)
-- Rotura de potencia, Salto y Combate por Equipos
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
-- Combate por Equipos, Salto y Rotura de potencia
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
    where NombreModalidad = "Combate por Equipos" or NombreModalidad = "Salto" or NombreModalidad = "Rotura de potencia"
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
insert into Maestro values(1, "Escuela 1", "Maestro 1", 1, "Sealand");
insert into Maestro values(2, "Escuela 2", "Maestro 2", 1, "Abjasia");

-- (NumeroCertificadoGraduacion, Foto, Graduacion, NombreCompleto, PlacaInstructor)
insert into Registrado values(1, null, 1, "A A", 1);
insert into Registrado values(2, null, 2, "B B", 2);
insert into Registrado values(3, null, 3, "C C", 1);
insert into Registrado values(4, null, 4, "D D", 2);
insert into Registrado values(5, null, 5, "E E", 1);
insert into Registrado values(6, null, 6, "F F", 2);
insert into Registrado values(7, null, 1, "G G", 1);
insert into Registrado values(8, null, 1, "H H", 2);

-- (NumeroCertificadoGraduacion, Peso, DNI, FechaNacimiento, Sexo, RolEquipo, NombreEquipo)
insert into Competidor values (1, 60, 12345671, "1994-05-06", "M", null, null);
insert into Competidor values (2, 70, 12345672, "1994-05-06", "M", null, null);
insert into Competidor values (3, 80, 12345673, "1994-05-06", "M", null, null);
insert into Competidor values (4, 90, 12345674, "1994-05-06", "M", null, null);
insert into Competidor values (5, 60, 12345675, "1994-05-06", "M", null, null);

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

-- Fin test medallero individual

-- (ID, Graduacion, NombreCompleto, NombrePais)
insert into Arbitro values(1, 6, "Arbitro 1", "Imperio Romano");
insert into Arbitro values(2, 6, "Arbitro 2", "Imperio Romano");
insert into Arbitro values(3, 6, "Arbitro 3", "Imperio Romano");
insert into Arbitro values(4, 6, "Arbitro 4", "Imperio Romano");
insert into Arbitro values(5, 6, "Arbitro 5", "Imperio Romano");
insert into Arbitro values(6, 6, "Arbitro 6", "Imperio Romano");
insert into Arbitro values(7, 6, "Arbitro 7", "Imperio Romano");

insert into Jurado values(1);

-- (IDJurado, IDArbitro, rol)
insert into Arbitraje values(1, 1, "arbitro central");
insert into Arbitraje values(1, 2, "presidente de mesa");
insert into Arbitraje values(1, 3, "juez");
insert into Arbitraje values(1, 4, "juez");
insert into Arbitraje values(1, 5, "suplente");
insert into Arbitraje values(1, 6, "suplente");
insert into Arbitraje values(1, 7, "suplente");

-- (Modalidad, IDJurado, Ring)
insert into ArbitradoPor values("Combate", 1, 1);

-- Fin test árbitros

insert into Equipo values("Los mas mejores");

-- (NumeroCertificadoGraduacion, Foto, Graduacion, NombreCompleto, PlacaInstructor)
insert into Registrado values(9, null, 5, "Nueve", 2);
insert into Registrado values(10, null, 5, "Diez", 2);
insert into Registrado values(11, null, 5, "Once", 2);
insert into Registrado values(12, null, 5, "Doce", 2);
insert into Registrado values(13, null, 5, "Trece", 2);
insert into Registrado values(14, null, 5, "Catorce", 2);
insert into Registrado values(15, null, 5, "Quince", 2);
insert into Registrado values(16, null, 5, "Dieciseis", 2);

-- (NumeroCertificadoGraduacion, Peso, DNI, FechaNacimiento, Sexo, RolEquipo, NombreEquipo)
insert into Competidor values (9, 60, 12345691, "1995-05-06", "F", "Titular", "Los mas mejores");
insert into Competidor values (10, 70, 12345692, "1995-05-06", "F", "Titular", "Los mas mejores");
insert into Competidor values (11, 80, 12345693, "1995-05-06", "F", "Titular", "Los mas mejores");
insert into Competidor values (12, 90, 12345694, "1995-05-06", "F", "Titular", "Los mas mejores");
insert into Competidor values (13, 60, 12345695, "1995-05-06", "F", "Titular", "Los mas mejores");
insert into Competidor values (14, 60, 12345696, "1995-05-06", "F", "Suplente", "Los mas mejores");
insert into Competidor values (15, 60, 12345697, "1995-05-06", "F", "Suplente", "Los mas mejores");
insert into Competidor values (16, 60, 12345608, "1995-05-06", "F", "Suplente", "Los mas mejores");

insert into Inscripto values (9, "Combate por Equipos");
insert into Inscripto values (10, "Combate por Equipos");
insert into Inscripto values (11, "Combate por Equipos");
insert into Inscripto values (12, "Combate por Equipos");
insert into Inscripto values (13, "Combate por Equipos");
insert into Inscripto values (14, "Combate por Equipos");
insert into Inscripto values (15, "Combate por Equipos");
insert into Inscripto values (16, "Combate por Equipos");

-- (IDParticipacion, Resultado, IDCategoria, NombreModalidad, NumeroCertificadoGraduacionCoach)
insert into Participacion values(4, 1, 8, "Combate por Equipos", "ParticipacionDeEquipo");

insert into ParticipacionDeEquipo values(4, "Los mas mejores");
