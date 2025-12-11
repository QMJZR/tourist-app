import http from '@ohos.net.http';
function httpRequest(url: string, method: http.RequestMethod, params?: string): Promise<string> {
  let httpRequest = http.createHttp();
  let responseResult = httpRequest.request(
    url, {
    method: method,
    readTimeout: 10000, // 读取超时时间，可选
    header: {
      'Content-Type': 'application/json' // 数据提交方式
    },
    connectTimeout: 10000, // 连接超时时间
    extraData: params
  }
  );
  let getjson: string = '';
  return responseResult.then((value: http.HttpResponse) => {
    console.log('请求状态 -- > ' + value.responseCode);
    if (value.responseCode === 200) {
      console.log("请求成功");
      let result = `${value.result}`;
      getjson = result;
    } else {
      getjson = '';
    }
    return getjson;
  }).catch(() => {
    httpRequest.destroy();
    return '';
  });
}

export function httpRequestGet(url: string, params?: string) {
  return httpRequest(url, http.RequestMethod.GET, params);
}

export function httpRequestPost(url: string, params?: string) {
  return httpRequest(url, http.RequestMethod.POST, params);
}
