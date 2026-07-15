import './envento_entity.dart';

final eventosFake = [
  EventoEntity(
    id: '1',
    titulo: 'Festival del Café Chiapaneco',
    descripcion:
        'El festival más importante del café de especialidad en Chiapas. '
        'Productores locales, catas guiadas, talleres de barismo y exposiciones '
        'sobre el proceso de cultivo del café de altura. Una experiencia sensorial '
        'única que celebra la tradición cafetera de los Altos de Chiapas.',
    fechaInicio: DateTime(2026, 7, 15),
    fechaFin: DateTime(2026, 7, 17),
    ubicacion: 'San Cristóbal de las Casas',
    categoria: 'Gastronomía',
    imageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80',
  ),
  EventoEntity(
    id: '2',
    titulo: 'Feria de las Culturas Indígenas',
    descripcion:
        'Celebración anual que reúne a comunidades indígenas de todo Chiapas. '
        'Exposición de artesanías, danza tradicional, música autóctona y '
        'gastronomía de las distintas etnias del estado. Entrada libre para '
        'toda la familia.',
    fechaInicio: DateTime(2026, 7, 20),
    fechaFin: DateTime(2026, 7, 25),
    ubicacion: 'Tuxtla Gutiérrez',
    categoria: 'Cultura',
    imageUrl:
        'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800&q=80',
  ),
  EventoEntity(
    id: '3',
    titulo: 'Taller de Barro Amatenango',
    descripcion:
        'Aprende la técnica ancestral de alfarería Tzeltal directamente con '
        'artesanas de Amatenango del Valle. El taller incluye materiales, '
        'guía experta y te llevas tu pieza terminada a casa.',
    fechaInicio: DateTime(2026, 7, 19),
    ubicacion: 'Amatenango del Valle',
    categoria: 'Talleres',
    imageUrl:
        'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=800&q=80',
  ),
  EventoEntity(
    id: '4',
    titulo: 'Senderismo Místico Nocturno',
    descripcion:
        'Recorrido nocturno por la selva lacandona con guías locales expertos. '
        'Observación de fauna nocturna, puntos de interés astronómico y '
        'una fogata al final del recorrido con historias de la cultura maya.',
    fechaInicio: DateTime(2026, 7, 27),
    ubicacion: 'Palenque',
    categoria: 'Festivales',
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
  ),
  EventoEntity(
    id: '5',
    titulo: 'Festival Gastronómico Chiapas 2026',
    descripcion:
        'El festival gastronómico más grande del sureste mexicano. '
        'Más de 50 restaurantes y productores locales presentan lo mejor '
        'de la cocina chiapaneca contemporánea y tradicional.',
    fechaInicio: DateTime(2026, 8, 3),
    fechaFin: DateTime(2026, 8, 5),
    ubicacion: 'San Cristóbal de las Casas',
    categoria: 'Gastronomía',
    imageUrl:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
  ),
  EventoEntity(
    id: '6',
    titulo: 'Feria del Ámbar Chiapaneco',
    descripcion:
        'Exposición y venta de ámbar chiapaneco, la joya más preciada del estado. '
        'Talleres de identificación, historia del ámbar y demostración de '
        'tallado artesanal por maestros joyeros locales.',
    fechaInicio: DateTime(2026, 8, 10),
    fechaFin: DateTime(2026, 8, 12),
    ubicacion: 'San Cristóbal de las Casas',
    categoria: 'Cultura',
    imageUrl:
        'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
  ),
];
