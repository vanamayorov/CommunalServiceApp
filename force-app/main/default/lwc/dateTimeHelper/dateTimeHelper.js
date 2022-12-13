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
    new Date(time).getMonth() < 9
      ? `0${new Date(time).getMonth() + 1}`
      : new Date(time).getMonth() + 1
  }.${new Date(time).getFullYear()}`;

export { getFormattedTime };
