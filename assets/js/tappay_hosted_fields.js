(function () {
  'use strict';

  // 避免重複初始化 SDK
  let sdkInitialized = false;

  // 紀錄每個 hostId 的清理函式
  const mounts = new Map(); // hostId -> cleanup()

  // 方便比對的取 iframe 函式
  function tpFrames() {
    return Array.from(document.querySelectorAll('iframe'))
      .filter(f => /tappay|tpdirect/i.test(f.src));
  }

  // ---- init ----
  window.tappayInit = function (appId, appKey, env) {
    try {
      if (!sdkInitialized) {
        TPDirect.setupSDK(appId, appKey, env); // 'sandbox' | 'production'
        sdkInitialized = true;
      }
      return true;
    } catch (e) {
      console.error('tappayInit error:', e);
      return false;
    }
  };

  // ---- render ----
  window.tappayRenderFields = function (hostId, opts) {
    try {
      // 已經 mount 過同一個 hostId 就不再重複 setup
      if (mounts.has(hostId)) return true;

      function mount() {
        const host = document.getElementById(hostId);
        // 等到元素真的掛到 DOM 再開始
        if (!host || !host.isConnected) {
          requestAnimationFrame(mount);
          return;
        }

        // 記錄 setup 前的 TP iframes
        const before = tpFrames();

        host.innerHTML = `
          <div class="tappay-container">
            <div class="full"><div id="card-number" class="tpfield"></div></div>
            <div><div id="card-expiration-date" class="tpfield"></div></div>
            <div><div id="card-ccv" class="tpfield"></div></div>
          </div>
        `;

        const setupOptions = opts && opts.fields ? opts : {
          fields: {
            number:         { element: '#card-number',            placeholder: '4000 0000 0000 0000' },
            expirationDate: { element: '#card-expiration-date',   placeholder: 'MM / YY' },
            ccv:            { element: '#card-ccv',               placeholder: '123' },
          },
          styles: {
            input:         { 'font-size': '16px' },
            ':focus':      { color: 'black' },
            '.valid':      { color: 'green' },
            '.invalid':    { color: 'red' },
            '::placeholder': { color: '#aaa' },
          },
        };

        TPDirect.card.setup(setupOptions);

        // 記錄 setup 後多出來的 TP iframes，打上歸屬方便清理
        const after  = tpFrames();
        const extras = after.filter(f => !before.includes(f));
        extras.forEach(f => f.setAttribute('data-tappay-owned', hostId));

        // 建立清理函式並記錄
        mounts.set(hostId, () => {
          try {
            const h = document.getElementById(hostId);
            if (h) h.innerHTML = ''; // 清掉 hosted fields (3 個 iframe)
            // 清掉這次 setup 產生的外掛 iframe（通常掛在 body）
            document
              .querySelectorAll(`iframe[data-tappay-owned="${hostId}"]`)
              .forEach(f => f.remove());
          } finally {
            mounts.delete(hostId);
          }
        });
      }

      requestAnimationFrame(mount);
      return true;
    } catch (e) {
      console.error('tappayRenderFields error:', e);
      return false;
    }
  };

  // ---- unmount ----
  window.tappayUnmountFields = function (hostId) {
    try {
      const cleanup = mounts.get(hostId);
      if (cleanup) cleanup();
      return true;
    } catch (e) {
      console.error('tappayUnmountFields error:', e);
      return false;
    }
  };

  // ---- getPrime ----
  window.tappayGetPrime = function (cb) {
    try {
      const status = TPDirect.card.getTappayFieldsStatus();
      if (!status.canGetPrime) {
        cb(null, { status: -1, message: 'Fields not ready', detail: status });
        return;
      }
      TPDirect.card.getPrime(function (result) {
        if (result.status === 0 && result.card && result.card.prime) {
          cb(result.card.prime, result);
        } else {
          cb(null, result);
        }
      });
    } catch (e) {
      console.error('tappayGetPrime error:', e);
      cb(null, { status: -99, message: e && e.message ? e.message : String(e) });
    }
  };
})();
