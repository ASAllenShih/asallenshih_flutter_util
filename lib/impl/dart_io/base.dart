class Stdout {
  bool get hasTerminal => false;
  int get terminalColumns => 0;
}

Stdout get stdout => Stdout();
