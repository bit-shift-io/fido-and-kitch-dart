mixin HasName {
  String _name;

  //@override
  get name {
    return _name;
  }

  set name(String n) {
    _name = n;
  }
}
