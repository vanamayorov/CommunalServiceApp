const getFormattedTime = (time) =>
  `${new Date(time).getHours()}:${
    new Date(time).getMinutes() < 10
      ? `0${new Date(time).getMinutes()}`
      : new Date(time).getMinutes()
  } ${
    new Date(time).getDate() < 10
      ? `0${new Date(time).getDate()}`
      : new Date(time).getDate()
  }.${
    new Date(time).getMonth() < 10
      ? `0${new Date(time).getMonth()}`
      : new Date(time).getMonth()
  }.${new Date(time).getFullYear()}`;

export { getFormattedTime };
