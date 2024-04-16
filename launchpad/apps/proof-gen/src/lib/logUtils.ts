const loggerFlag = process.argv[2]?.concat(process.argv[3] ?? '') ?? 'Main';

const pinoObj = pino({
  name: loggerFlag,
  timestamp: pino.stdTimeFunctions.isoTime,
  transport: {
    targets: [
      {
        target: 'pino/file',
        level: 'info',
        options: { destination: config.pinoLogFilePath.concat(`/proof-generators-${loggerFlag}.log`) }
      },
      { target: 'pino-pretty', level: 'info', options: { destination: '/dev/stdout' } }
    ]
  }
});

const childLoggerMap = new Map<string, Logger>();

// TODO need configure file storage, pattern, etc.
export function getLogger(childSegment?: string): Logger {
  if (!childSegment) {
    return pinoObj;
  }
  if (!childLoggerMap.get(childSegment)) {
    childLoggerMap.set(childSegment, pinoObj.child({ segment: childSegment }));
  }

  return childLoggerMap.get(childSegment)!;
}

logrotator: {
  byDay: true,
    dayDelimiter: '_'
},
maxBufferLength: 4096,
  flushInterval: 1000,
    customLevels: 'all',
      prettyPrint: {
  colorize: false,
    timestampKey: 'time',
      translateTime: 'yyyy-mm-dd HH:MM:ss.l',
        messageFormat: '{msg}'
}
   };
