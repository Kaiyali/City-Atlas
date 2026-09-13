export function combinedValue(stats, topicState) {
  if (!stats) return null;
  const keys = Object.entries(topicState)
    .filter(([, on]) => on)
    .map(([id]) => id);
  if (!keys.length) return null;

  let sum = 0;
  let any = false;
  keys.forEach((key) => {
    if (typeof stats[key] === 'number') {
      sum += stats[key];
      any = true;
    }
  });
  return any ? sum : null;
}

export function emptyYearStats() {
  return {
    assault: 0,
    robbery: 0,
    autoTheft: 0,
    breakEnter: 0,
    theft: 0,
    theftFromMv: 0,
  };
}

export function yearStatsFromRow(row) {
  if (!row) return null;
  return {
    assault: toCount(row.Assault),
    robbery: toCount(row.Robbery),
    autoTheft: toCount(row['Auto Theft']),
    breakEnter: toCount(row['Break & Enter']),
    theft: toCount(row['Theft Over']),
    theftFromMv: toCount(row['Theft From MV']),
  };
}

export function addYearStats(left, right) {
  const next = emptyYearStats();
  Object.keys(next).forEach((key) => {
    const a = left?.[key];
    const b = right?.[key];
    if (typeof a === 'number' || typeof b === 'number') {
      next[key] = (typeof a === 'number' ? a : 0) + (typeof b === 'number' ? b : 0);
    } else {
      next[key] = null;
    }
  });
  return next;
}

function toCount(value) {
  return typeof value === 'number' ? value : null;
}
