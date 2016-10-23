class NativeAjax {
  _csrfToken() {
    return this.csrfToken || (this.csrfToken = document.head.querySelector('meta[name="csrf-token"]').content);
  }
  static _parseResponse(response) {
    let mimeType = response.getResponseHeader('Content-Type');
    if (mimeType && mimeType.startsWith('application/json') && response.responseText !== '') {
      return JSON.parse(response.responseText);
    } else {
      return response.responseText;
    }
  }
  static _issueRequest(req, opts) {
    let payload = opts.data;
    if (opts.contentType) {
      req.setRequestHeader('Content-Type', opts.contentType);
      if (opts.contentType === 'application/json') {
        payload = JSON.stringify(opts.data);
      }
    }
    req.send(payload);
  }
  static _addRequestParameters(request, opts) {
    if (opts.acceptType) {
      request.setRequestHeader('Accept', opts.acceptType);
    }
  }
  static _processResponse(request, resolve, reject) {
    return () => {
      const body = NativeAjax._parseResponse(request);
      if (request.status >= 200 && request.status < 300) {
        resolve(body);
      } else {
        reject(body);
      }
    };
  }
  get(url, opts = {}) {
    let params;
    if (opts.data) {
      params = '?' + Object.keys(opts.data).map((key) => encodeURIComponent(key) + '=' + encodeURIComponent(opts.data[key]));
    } else {
      params = '';
    }
    return new Promise((resolve, reject) => {
      const request = new XMLHttpRequest();
      request.open('GET', url + params, true);
      NativeAjax._addRequestParameters(request, opts);
      request.onload = NativeAjax._processResponse(request, resolve, reject);
      request.send();
    });
  }
  post(url, opts = {}) {
    const request = new XMLHttpRequest();
    const promise = new Promise((resolve, reject) => {
      request.open('POST', url, true);
      NativeAjax._addRequestParameters(request, opts);
      request.setRequestHeader('X-CSRF-Token', this._csrfToken());
      request.onload = NativeAjax._processResponse(request, resolve, reject);
      NativeAjax._issueRequest(request, opts);
    });
    promise.abort = request.abort;
    return promise;
  }
}

const Ajax = new NativeAjax();
