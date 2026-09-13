import { useState, useEffect } from 'react';
import MapComponent from './MapComponent';
import ThemeToggle from './ThemeToggle';
import CityArrows from './CityArrows';
import CityNav from './CityNav';
import TopicSidebar from './TopicSidebar';
import YearTimeline from './YearTimeline';
import { CITIES, getCity } from './cities';
import { DEFAULT_TOPICS } from './topics';
import './index.css';

function App() {
  const [isDarkMode, setIsDarkMode] = useState(() => {
    const saved = localStorage.getItem('theme');
    return saved ? JSON.parse(saved) : false;
  });
  const [city, setCity] = useState(() => {
    const saved = localStorage.getItem('city');
    return getCity(saved).id;
  });
  const [topics, setTopics] = useState(DEFAULT_TOPICS);
  const [year, setYear] = useState(2024);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(() => {
    const saved = localStorage.getItem('sidebarCollapsed');
    return saved ? JSON.parse(saved) : false;
  });

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', isDarkMode ? 'dark' : 'light');
    localStorage.setItem('theme', JSON.stringify(isDarkMode));
  }, [isDarkMode]);

  useEffect(() => {
    localStorage.setItem('city', city);
  }, [city]);

  useEffect(() => {
    localStorage.setItem('sidebarCollapsed', JSON.stringify(sidebarCollapsed));
  }, [sidebarCollapsed]);

  const toggleTopic = (id) => {
    setTopics((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  return (
    <div className={`app-shell ${sidebarCollapsed ? 'is-sidebar-collapsed' : ''}`}>
      <div className="atlas-glow" aria-hidden="true" />
      <TopicSidebar
        topics={topics}
        onToggle={toggleTopic}
        collapsed={sidebarCollapsed}
        onCollapsedChange={setSidebarCollapsed}
      />
      <ThemeToggle isDarkMode={isDarkMode} toggleTheme={() => setIsDarkMode((prev) => !prev)} />

      <main className="atlas-main">
        <CityArrows cityId={city} cities={CITIES} onCityChange={setCity} />
        <MapComponent
          key={city}
          cityId={city}
          isDarkMode={isDarkMode}
          topics={topics}
          year={year}
        />
        <CityNav city={city} />
        <YearTimeline year={year} onYearChange={setYear} />
      </main>
    </div>
  );
}

export default App;
