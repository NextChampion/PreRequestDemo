import Network from '../utils/Network';

const domain = 'http://v.juhe.cn/toutiao/index';
const APPKEY = 'b6a70a0df051ea3e4b7e62f90e17e1a3';

export function getNews(params = null) {
  const url = domain + '?' + 'type=top&key=' + APPKEY;
  console.log('url', url);
  return Network.post(url, params);
}
