export default class ModelCache {
  static get(group, id) {
    const key = group + '/' + id;
    if (ModelCache.cache.hasOwnProperty(key)) {
      return ModelCache.cache[key];
    }

    const val = new group({id: id});
    ModelCache.cache[key] = val;
    return val;
  }
}

ModelCache.cache = new Map();
