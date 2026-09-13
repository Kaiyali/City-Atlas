import { getCity } from './cities';

function CityNav({ city }) {
  const current = getCity(city);

  return (
    <p className="city-nav" aria-current="page">
      {current.label}
    </p>
  );
}

export default CityNav;
