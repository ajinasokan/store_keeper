abstract class M {
  M() {
    print("M");
    exec();
  }
  void exec();
}

class I extends M {
  final int x;

  I({this.x});

  void exec() {
    print(x);
    print("exec");
  }
}

void main() {
  I(x: 10);
}
