function CityArrows({ cityId, cities, onCityChange }) {
  const index = Math.max(0, cities.findIndex((city) => city.id === cityId));
  const prev = cities[(index - 1 + cities.length) % cities.length];
  const next = cities[(index + 1) % cities.length];

  return (
    <>
      <button
        type="button"
        className="city-arrow city-arrow-left"
        aria-label={`Previous city, ${prev.label}`}
        onClick={() => onCityChange(prev.id)}
      >
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M14.5 5.5 8 12l6.5 6.5" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
      <button
        type="button"
        className="city-arrow city-arrow-right"
        aria-label={`Next city, ${next.label}`}
        onClick={() => onCityChange(next.id)}
      >
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M9.5 5.5 16 12l-6.5 6.5" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
    </>
  );
}

export default CityArrows;
