const exec = require("cordova/exec");
module.exports = {
  /**
   * @param {(available: boolean, error?:any)=>void} callback
   */
  isAvailable: function (callback) {
    const errorHandler = function errorHandler(error) {
      // An error has occurred while trying to access the
      // SafariViewController native implementation, most likely because
      // we are on an unsupported platform.
      callback(false, error);
    };
    exec(callback, errorHandler, "SafariViewController", "isAvailable", []);
  },
  /**
   *
   * @param {*} options
   * @param {(message:{event:string})=>void} [onMessage]
   * @param {(error:any)=>void} [onError]
   */
  show: function (options, onMessage, onError) {
    options = options || {};
    if (!options.hasOwnProperty('animated')) {
      options.animated = true;
    }
    exec(onMessage, onError, "SafariViewController", "show", [options]);
  },
  /**
   * @param {()=>void} [onSuccess]
   * @param {(error:any)=>void} [onError]
   */
  hide: function (onSuccess, onError) {
    exec(onSuccess, onError, "SafariViewController", "hide", []);
  },
  /**
   * available on Android only
   * @param {(packages:Array<?>)=>void} onSuccess
   * @param {(error:any)=>void} [onError]
   */
  getViewHandlerPackages: function (onSuccess, onError) {
    exec(onSuccess, onError, "SafariViewController", "getViewHandlerPackages", []);
  },
  /**
   * available on Android only
   * @param {()=>void} [onSuccess]
   * @param {(error:any)=>void} [onError]
   */
  useChrome: function (onSuccess, onError) {
    exec(onSuccess, onError, "SafariViewController", "useChrome", []);
  },
  /**
   * available on Android only
   * @param {string} packageName
   * @param {()=>void} [onSuccess]
   * @param {(error:any)=>void} [onError]
   */
  useCustomTabsImplementation: function (packageName, onSuccess, onError) {
    exec(onSuccess, onError, "SafariViewController", "useCustomTabsImplementation", [packageName]);
  },
  /**
   * available on Android only
   * @param {()=>void} onSuccess
   * @param {(error:any)=>void} onError
   */
  connectToService: function ([onSuccess], [onError]) {
    exec(onSuccess, onError, "SafariViewController", "connectToService", []);
  },
  /**
   * available on Android only
   * @param {()=>void} onSuccess
   * @param {(error:any)=>void} onError
   */
  warmUp: function ([onSuccess], [onError]) {
    exec(onSuccess, onError, "SafariViewController", "warmUp", []);
  },
  /**
   * available on Android only
   * @param {string} url
   * @param {()=>void} [onSuccess]
   * @param {(error:any)=>void} [onError]
   */
  mayLaunchUrl: function (url, onSuccess, onError) {
    exec(onSuccess, onError, "SafariViewController", "mayLaunchUrl", [url]);
  }
};
