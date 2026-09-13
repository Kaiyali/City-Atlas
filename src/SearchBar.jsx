import { useEffect, useMemo, useRef, useState } from 'react';

function displayName(name = '') {
  return name.replace(/\s*\(\d+\)\s*$/, '').trim();
}

function SearchBar({ city, hoodNames, selectedHood, onSelect }) {
  const [query, setQuery] = useState('');
  const [open, setOpen] = useState(false);
  const rootRef = useRef(null);
  const current = selectedHood ? displayName(selectedHood) : city.allLabel;

  useEffect(() => {
    setQuery('');
    setOpen(false);
  }, [city.id]);

  useEffect(() => {
    const onPointer = (event) => {
      if (!rootRef.current?.contains(event.target)) setOpen(false);
    };
    document.addEventListener('pointerdown', onPointer);
    return () => document.removeEventListener('pointerdown', onPointer);
  }, []);

  const matches = useMemo(() => {
    const q = query.trim().toLowerCase();
    const names = hoodNames.map((name) => ({ name, label: displayName(name) }));
    if (!q) return names.slice(0, 12);
    return names.filter((item) => item.label.toLowerCase().includes(q)).slice(0, 12);
  }, [hoodNames, query]);

  return (
    <div className="search-bar" ref={rootRef}>
      <svg className="search-icon" viewBox="0 0 24 24" aria-hidden="true">
        <circle cx="11" cy="11" r="6.5" fill="none" stroke="currentColor" strokeWidth="1.6" />
        <path d="M16.2 16.2 20 20" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
      </svg>
      <span className="search-divider" />
      <input
        className="search-input"
        value={open ? query : current}
        placeholder={city.allLabel}
        onFocus={() => {
          setOpen(true);
          setQuery('');
        }}
        onChange={(event) => {
          setOpen(true);
          setQuery(event.target.value);
        }}
        aria-label="Search neighbourhoods"
      />
      {open && (
        <ul className="search-results">
          <li>
            <button type="button" onClick={() => { onSelect(''); setOpen(false); setQuery(''); }}>
              {city.allLabel}
            </button>
          </li>
          {matches.map((item) => (
            <li key={item.name}>
              <button type="button" onClick={() => { onSelect(item.name); setOpen(false); setQuery(''); }}>
                {item.label}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default SearchBar;
