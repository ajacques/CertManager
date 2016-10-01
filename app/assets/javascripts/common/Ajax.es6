class NativeAjax {
  _csrfToken() {
    return this.csrfToken || (this.csrfToken = document.head.querySelector('meta[name="csrf-token"]').content);
  }
  _parseResponse(response) {
    let mimeType = response.getResponseHeader('Content-Type');
    if (mimeType && mimeType.startsWith('application/json') && response.responseText !== '') {
      return JSON.parse(response.responseText);
    } else {
      return response.responseText;
    }
  }
  _addRequestParameters(request, opts) {
    if (opts.acceptType) {
      request.setRequestHeader('Accept', opts.acceptType);
    }
  }
  _processResponse(request, resolve, reject) {
    return () => {
      const body = this._parseResponse(request);
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
      this._addRequestParameters(request, opts);
      request.onload = this._processResponse(request, resolve, reject);
      request.send(JSON.stringify(opts.data));
    });
  }
  post(url, opts = {}) {
    return new Promise((resolve, reject) => {
      let request = new XMLHttpRequest();
      request.open('POST', url, true);
      this._addRequestParameters(request, opts);
      request.setRequestHeader('Content-Type', opts.contentType);
      request.setRequestHeader('X-CSRF-Token', this._csrfToken());
      request.onload = this._processResponse(request, resolve, reject);
      request.send(JSON.stringify(opts.data));
    });
  }
}

const Ajax = new NativeAjax();
