class TextAniElement extends PElement {
  final List<TextAniRequest> _requests;

  TextAniElement(num width, num height) :
    _requests = new List<TextAniRequest>(),
    super(width, height);

  void add(TextAniRequest request) {
    assert(request != null);
    assert(request.fresh);
    _requests.add(request);
    invalidateDraw();
  }

  void update() {

    var toRemove = new List<TextAniRequest>();
    for(final r in _requests) {
      r.update();
      assert(!r.fresh);
      if(r.done) {
        toRemove.add(r);
      }
    }

    for(final r in toRemove) {
      final i = _requests.indexOf(r, 0);
      assert(i >= 0);
      _requests.removeRange(i, 1);
    }

    if(_requests.length > 0) {
      invalidateDraw();
    }
  }

  void drawOverride(CanvasRenderingContext2D ctx) {
    for(final r in _requests) {
      r.drawOverride(ctx);
    }
  }
}

class TextAniRequest {
  final String _texturePrefix;
  final int _frameCount;
  final dartlib.Vector _offset;

  bool _done = false;
  int _frame = null;

  TextAniRequest(this._texturePrefix, this._frameCount, this._offset) {
    assert(_texturePrefix != null);
    assert(_frameCount > 0);
    assert(_offset.isValid);
  }

  bool get fresh => _frame == null;
  bool get done => _done;

  void update() {
    if(_frame == null) {
      _frame = 0;
    } else if(_frame < (_frameCount - 1)){
      _frame++;
      assert(_frame < _frameCount);
    } else {
      _done = true;
    }
  }

  void drawOverride(CanvasRenderingContext2D ctx) {
    var frameString = _frame.toString();
    while(frameString.length < 4) {
      frameString = "0$frameString";
    }

    final frameName = "${_texturePrefix}_$frameString.png";

    ctx.save();
    ctx.translate(_offset.x, _offset.y);
    drawTextureKeyAt(ctx, frameName);
    ctx.restore();
  }
}