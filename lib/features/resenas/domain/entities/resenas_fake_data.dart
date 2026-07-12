import 'resena_entity.dart';

final destinosFake = [
  const DestinoResenaEntity(
    id: '1',
    nombre: 'Cascadas de Agua Azul',
    ubicacion: 'Palenque, Chiapas',
    tipo: 'Naturaleza',
    calificacion: 4.8,
    totalResenas: 342,
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    esPopular: true,
  ),
  const DestinoResenaEntity(
    id: '2',
    nombre: 'El Fogón de Jovel',
    ubicacion: 'San Cristóbal, Chiapas',
    tipo: 'Restaurante',
    calificacion: 4.7,
    totalResenas: 218,
    imageUrl:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
  ),
  const DestinoResenaEntity(
    id: '3',
    nombre: 'Selva Verde Eco-Resort',
    ubicacion: 'Ocosingo, Chiapas',
    tipo: 'Hotel',
    calificacion: 4.9,
    totalResenas: 156,
    imageUrl:
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80',
  ),
  const DestinoResenaEntity(
    id: '4',
    nombre: 'Zona Arqueológica Palenque',
    ubicacion: 'Palenque, Chiapas',
    tipo: 'Cultura',
    calificacion: 4.6,
    totalResenas: 489,
    imageUrl:
        'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
    esPopular: true,
  ),
  const DestinoResenaEntity(
    id: '5',
    nombre: 'Café Maya Luxury',
    ubicacion: 'San Cristóbal, Chiapas',
    tipo: 'Restaurante',
    calificacion: 4.9,
    totalResenas: 203,
    imageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80',
  ),
  const DestinoResenaEntity(
    id: '6',
    nombre: 'Cañón del Sumidero',
    ubicacion: 'Tuxtla Gutiérrez, Chiapas',
    tipo: 'Naturaleza',
    calificacion: 4.7,
    totalResenas: 621,
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
    esPopular: true,
  ),
];

final resenasFake = [
  const ResenaEntity(
    id: '1',
    autorNombre: 'Mariana Solís',
    autorTipo: 'Local Guide',
    calificacion: 5.0,
    comentario:
        'Una experiencia inolvidable. El color del agua es simplemente irreal. Recomiendo llegar temprano (antes de las 9 AM) para evitar las multitudes y disfrutar de la paz absoluta. El sendero está bien cuidado.',
    fechaRelativa: 'Hace 2 días',
    likes: 24,
    respuestas: 2,
    fotos: [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',
    ],
  ),
  const ResenaEntity(
    id: '2',
    autorNombre: 'Carlos Ruiz',
    autorTipo: 'Fotógrafo',
    calificacion: 4.0,
    comentario:
        'Espectacular para fotografía. Si vas en época de lluvias, el agua puede verse un poco más café por los sedimentos, pero sigue siendo majestuoso. Los puestos de comida local cerca de la entrada son excelentes.',
    fechaRelativa: 'Hace 1 semana',
    likes: 15,
    respuestas: 0,
    fotos: [
      'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=400&q=80',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',
    ],
  ),
  const ResenaEntity(
    id: '3',
    autorNombre: 'Ana García',
    autorTipo: 'Turista Nacional',
    calificacion: 5.0,
    comentario:
        'Definitivamente uno de los lugares más hermosos que he visitado en México. El agua turquesa es simplemente mágica. Llevé a mis hijos y quedaron fascinados.',
    fechaRelativa: 'Hace 2 semanas',
    likes: 31,
    respuestas: 4,
  ),
  const ResenaEntity(
    id: '4',
    autorNombre: 'Roberto Méndez',
    autorTipo: 'Turista Extranjero',
    calificacion: 4.5,
    comentario:
        'Beautiful place! The waterfalls are stunning. A bit crowded on weekends but totally worth it. The local food stands nearby have amazing tamales.',
    fechaRelativa: 'Hace 3 semanas',
    likes: 8,
    respuestas: 1,
  ),
];