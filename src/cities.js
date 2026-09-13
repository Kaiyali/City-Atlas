export const CITIES = [
  {
    id: 'toronto',
    label: 'Toronto',
    province: 'Ontario',
    geojson: '/toronto_crs84.geojson',
    center: [43.72, -79.38],
    hasCrime: true,
    allLabel: 'All of Toronto',
  },
  {
    id: 'montreal',
    label: 'Montreal',
    province: 'Quebec',
    geojson: '/montreal.geojson',
    center: [45.52, -73.65],
    hasCrime: true,
    allLabel: 'All of Montreal',
  },
  {
    id: 'vancouver',
    label: 'Vancouver',
    province: 'British Columbia',
    geojson: '/vancouver.geojson',
    center: [49.25, -123.12],
    hasCrime: true,
    allLabel: 'All of Vancouver',
  },
];

export function getCity(id) {
  return CITIES.find((city) => city.id === id) ?? CITIES[0];
}
