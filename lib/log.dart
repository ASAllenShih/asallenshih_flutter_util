import 'impl/dart_io.dart';
import 'package:logger/logger.dart';

class Log {
  static Level? level;
  static LogFilter? filter;
  static LogPrinter? printer;
  static LogOutput? output;
  static bool emojis = true;
  static bool colors = true;
  static bool colorsGrep = false;
  static int stackTraceBeginIndex = 0;
  static String Function(DateTime) dateTimeFormat = DateTimeFormat.dateAndTime;
  static PrettyPrinter get _prettyPrinter => PrettyPrinter(
    stackTraceBeginIndex: stackTraceBeginIndex + 3,
    methodCount: 3,
    errorMethodCount: 10,
    lineLength: stdout.terminalColumns,
    colors: colors && !colorsGrep && stdout.hasTerminal,
    printEmojis: emojis,
    dateTimeFormat: dateTimeFormat,
  );
  static LogPrinter get _printer =>
      printer ?? (colorsGrep ? PrefixPrinter(_prettyPrinter) : _prettyPrinter);
  static Logger get logger =>
      Logger(filter: filter, printer: _printer, output: output, level: level);
}

Logger get log => Log.logger;
