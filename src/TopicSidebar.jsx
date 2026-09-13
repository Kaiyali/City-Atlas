import { TOPICS } from './topics';

function TopicSidebar({ topics, onToggle, collapsed, onCollapsedChange }) {
  return (
    <aside
      className={`topic-sidebar ${collapsed ? 'is-collapsed' : ''}`}
      aria-label="Topics"
    >
      <div className="topic-sidebar-head">
        {!collapsed && <h1 className="topic-sidebar-title">Topics</h1>}
        <button
          type="button"
          className="topic-sidebar-toggle"
          aria-expanded={!collapsed}
          aria-label={collapsed ? 'Open topics' : 'Collapse topics'}
          onClick={() => onCollapsedChange(!collapsed)}
        >
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 7h14M5 12h14M5 17h14" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
          </svg>
        </button>
      </div>

      {!collapsed && (
        <ul className="topic-list">
          {TOPICS.map((topic) => {
            const on = Boolean(topics[topic.id]);
            return (
              <li key={topic.id}>
                <div className="topic-row">
                  <span className="topic-label">{topic.label}</span>
                  <button
                    type="button"
                    className={`topic-switch ${on ? 'is-on' : ''}`}
                    role="switch"
                    aria-checked={on}
                    aria-label={`${topic.label}, ${on ? 'on' : 'off'}`}
                    onClick={() => onToggle(topic.id)}
                  >
                    <span className="topic-switch-knob" />
                  </button>
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </aside>
  );
}

export default TopicSidebar;
