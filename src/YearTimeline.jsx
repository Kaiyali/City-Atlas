import { YEARS } from './topics';

function nearestYear(clientX, track) {
  const rect = track.getBoundingClientRect();
  const ratio = rect.width ? Math.min(1, Math.max(0, (clientX - rect.left) / rect.width)) : 1;
  const index = Math.round(ratio * (YEARS.length - 1));
  return YEARS[index];
}

function YearTimeline({ year, onYearChange }) {
  const index = Math.max(0, YEARS.indexOf(year));
  const fill = YEARS.length > 1 ? (index / (YEARS.length - 1)) * 100 : 0;

  const scrub = (event) => {
    onYearChange(nearestYear(event.clientX, event.currentTarget));
  };

  return (
    <div className="year-timeline">
      <div
        className="year-timeline-track"
        role="slider"
        tabIndex={0}
        aria-label="Year"
        aria-valuemin={YEARS[0]}
        aria-valuemax={YEARS[YEARS.length - 1]}
        aria-valuenow={year}
        onPointerDown={scrub}
        onPointerMove={(event) => {
          if (event.buttons === 1) scrub(event);
        }}
        onKeyDown={(event) => {
          if (event.key === 'ArrowLeft' && index > 0) onYearChange(YEARS[index - 1]);
          if (event.key === 'ArrowRight' && index < YEARS.length - 1) onYearChange(YEARS[index + 1]);
        }}
      >
        <span className="year-timeline-line" />
        <span className="year-timeline-fill" style={{ width: `${fill}%` }} />
        {YEARS.map((item, i) => (
          <button
            key={item}
            type="button"
            className={`year-dot ${item === year ? 'is-active' : ''} ${item < year ? 'is-past' : ''}`}
            style={{ left: `${(i / (YEARS.length - 1)) * 100}%` }}
            aria-label={String(item)}
            aria-pressed={item === year}
            onClick={() => onYearChange(item)}
          />
        ))}
      </div>
      <div className="year-timeline-labels">
        {YEARS.map((item) => (
          <button
            key={item}
            type="button"
            className={item === year ? 'is-active' : ''}
            onClick={() => onYearChange(item)}
          >
            {item}
          </button>
        ))}
      </div>
    </div>
  );
}

export default YearTimeline;
