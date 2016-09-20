class NativeAjax {
  _csrfToken() {
    return document.head.querySelector('meta[name="csrf-token"]').content;
  }
  _parseResponse(response) {
    let mimeType = response.getResponseHeader('Content-Type');
    if (mimeType && mimeType.startsWith('application/json')) {
      return JSON.parse(response.responseText);
    } else {
      return response.responseText;
    }
  }
  get(url, opts = {}) {
    let params;
    if (opts.data) {
      params = '?' + Object.keys(opts.data).map((key) => encodeURIComponent(key) + '=' + encodeURIComponent(opts.data[key]));
    } else {
      params = '';
    }
    return new Promise((resolve, reject) => {
      let request = new XMLHttpRequest();
      request.open('GET', url + params, true);
      request.setRequestHeader('Accept', opts.acceptType);
      request.onload = () => {
        let body = this._parseResponse(request);
        if (request.status == 200) {
          resolve(body);
        } else {
          reject(body);
        }
      };
      request.send(JSON.stringify(opts.data));
    });
  }
  post(url, opts = {}) {
    return new Promise((resolve, reject) => {
      let request = new XMLHttpRequest();
      request.open('POST', url, true);
      request.setRequestHeader('Content-Type', opts.contentType);
      request.setRequestHeader('X-CSRF-Token', this._csrfToken());
      request.onload = () => {
        if (request.status == 200) {
          resolve(this._parseResponse(request));
        } else {
          reject(request.responseText);
        }
      };
      request.send(JSON.stringify(opts.data));
    });
  }
}

class jQueryAjax {
  get(url, opts = {}) {
    let props = {
      type: 'get',
      accepts: opts.acceptType,
      data: opts.data
    };
    return $.ajax(url, props);
  }
  post(url, opts = {}) {
    let input;
    if (opts.contentType == 'application/json'){
      input = JSON.stringify(opts.data);
    } else {
      input = opts.data;
    }
    let props = {
      type: 'post',
      contentType: opts.contentType,
      accepts: opts.acceptType,
      data: input
    };
    return $.ajax(url, props);
  }
}

const Ajax = new NativeAjax();
