import { apiInitializer } from "discourse/lib/api";

const CLOSED_FLAG_KEY = "icarsoft_prelaunch_popup_closed";
const LAUNCH_DATE_ISO = "2025-12-15T00:00:00+01:00";

function hasWindow() {
  return typeof window !== "undefined" && typeof document !== "undefined";
}

function getSessionFlag() {
  if (!hasWindow()) {
    return false;
  }

  try {
    return window.sessionStorage.getItem(CLOSED_FLAG_KEY) === "true";
  } catch {
    return false;
  }
}

function setSessionFlag() {
  if (!hasWindow()) {
    return;
  }

  try {
    window.sessionStorage.setItem(CLOSED_FLAG_KEY, "true");
  } catch {
    // Ignore storage errors (private mode, etc.)
  }
}

function ensureOverlay() {
  let overlay = document.querySelector(".icarsoft-prelaunch-overlay");

  if (!overlay) {
    overlay = document.createElement("div");
    overlay.className = "icarsoft-prelaunch-overlay";
    overlay.setAttribute("role", "dialog");
    overlay.setAttribute("aria-modal", "true");
    overlay.setAttribute("aria-labelledby", "icarsoft-prelaunch-title");

    overlay.innerHTML = `
      <div class="icarsoft-prelaunch-popup">
        <div class="icarsoft-prelaunch-card">
          <header class="icarsoft-prelaunch-header">
            <div class="icarsoft-prelaunch-pill">Annonce</div>
            <h2 id="icarsoft-prelaunch-title" class="icarsoft-prelaunch-title">
              Forum en préparation
            </h2>
            <p class="icarsoft-prelaunch-subtitle">
              Notre forum est actuellement fermé. Le lancement est prévu pour le <strong>15/12/2025</strong>.
            </p>
          </header>

          <section class="icarsoft-prelaunch-countdown-wrapper">
            <p class="icarsoft-prelaunch-countdown-label">
              Ouverture dans
            </p>
            <div class="icarsoft-prelaunch-countdown" data-context="popup">
              <div class="icarsoft-prelaunch-countdown-unit">
                <span class="value" data-unit="days">00</span>
                <span class="label">Jours</span>
              </div>
              <div class="icarsoft-prelaunch-countdown-unit">
                <span class="value" data-unit="hours">00</span>
                <span class="label">Heures</span>
              </div>
              <div class="icarsoft-prelaunch-countdown-unit">
                <span class="value" data-unit="minutes">00</span>
                <span class="label">Minutes</span>
              </div>
              <div class="icarsoft-prelaunch-countdown-unit">
                <span class="value" data-unit="seconds">00</span>
                <span class="label">Secondes</span>
              </div>
            </div>
          </section>

          <footer class="icarsoft-prelaunch-footer">
            <p class="icarsoft-prelaunch-note">
              Vous pouvez déjà parcourir le contenu en lecture seule. Les inscriptions et les réponses seront ouvertes à partir du lancement.
            </p>
            <button type="button" class="icarsoft-prelaunch-close">
              J&apos;ai compris
            </button>
          </footer>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);

    const closeBtn = overlay.querySelector(".icarsoft-prelaunch-close");
    if (closeBtn) {
      closeBtn.addEventListener("click", () => {
        setSessionFlag();
        updateVisibility();
      });
    }
  }

  return overlay;
}

function ensureBanner() {
  let banner = document.querySelector(".icarsoft-prelaunch-banner");

  if (!banner) {
    banner = document.createElement("div");
    banner.className = "icarsoft-prelaunch-banner";
    banner.innerHTML = `
      <div class="icarsoft-prelaunch-banner-inner">
        <div class="icarsoft-prelaunch-banner-text">
          <span class="icarsoft-prelaunch-dot"></span>
          <span>
            Notre forum est actuellement fermé. Le lancement est prévu pour le <strong>15/12/2025</strong>.
          </span>
        </div>
        <div class="icarsoft-prelaunch-countdown icarsoft-prelaunch-countdown--compact" data-context="banner">
          <div class="icarsoft-prelaunch-countdown-unit">
            <span class="value" data-unit="days">00</span>
            <span class="label">J</span>
          </div>
          <div class="icarsoft-prelaunch-countdown-unit">
            <span class="value" data-unit="hours">00</span>
            <span class="label">H</span>
          </div>
          <div class="icarsoft-prelaunch-countdown-unit">
            <span class="value" data-unit="minutes">00</span>
            <span class="label">Min</span>
          </div>
          <div class="icarsoft-prelaunch-countdown-unit">
            <span class="value" data-unit="seconds">00</span>
            <span class="label">Sec</span>
          </div>
        </div>
      </div>
    `;
    // Default insertion; we may reposition relative to the header below
    document.body.appendChild(banner);
  }

  // Keep the banner visually attached to the Discourse header when possible
  const header = document.querySelector(".d-header");

  if (header && header.parentNode && banner.parentNode !== header.parentNode) {
    header.parentNode.insertBefore(banner, header.nextSibling);
  }

  if (header) {
    const headerHeight = header.offsetHeight || 60;
    banner.style.top = `${headerHeight}px`;
  } else if (!banner.style.top) {
    // Fallback so the banner stays visible even if the header structure differs
    banner.style.top = "0";
  }

  return banner;
}

let countdownInterval = null;

function updateCountdown() {
  if (!hasWindow()) {
    return;
  }

  const now = new Date();
  const target = new Date(LAUNCH_DATE_ISO);
  const total = target.getTime() - now.getTime();

  let days = 0;
  let hours = 0;
  let minutes = 0;
  let seconds = 0;

  if (total > 0) {
    seconds = Math.floor((total / 1000) % 60);
    minutes = Math.floor((total / 1000 / 60) % 60);
    hours = Math.floor((total / (1000 * 60 * 60)) % 24);
    days = Math.floor(total / (1000 * 60 * 60 * 24));
  }

  const pad = (value) => String(value).padStart(2, "0");

  const containers = document.querySelectorAll(".icarsoft-prelaunch-countdown");
  containers.forEach((container) => {
    container.querySelectorAll("[data-unit]").forEach((element) => {
      const unit = element.getAttribute("data-unit");

      switch (unit) {
        case "days":
          element.textContent = pad(days);
          break;
        case "hours":
          element.textContent = pad(hours);
          break;
        case "minutes":
          element.textContent = pad(minutes);
          break;
        case "seconds":
          element.textContent = pad(seconds);
          break;
        default:
          break;
      }
    });
  });

  if (total <= 0 && countdownInterval) {
    window.clearInterval(countdownInterval);
    countdownInterval = null;

    const subtitles = document.querySelectorAll(".icarsoft-prelaunch-subtitle");
    subtitles.forEach((element) => {
      element.textContent = "Le forum est maintenant ouvert.";
    });
  }
}

function startCountdown() {
  if (!hasWindow()) {
    return;
  }

  updateCountdown();

  if (!countdownInterval) {
    countdownInterval = window.setInterval(updateCountdown, 1000);
  }
}

function updateVisibility() {
  if (!hasWindow()) {
    return;
  }

  const overlay = ensureOverlay();
  const banner = ensureBanner();
  const closed = getSessionFlag();

  if (!closed) {
    overlay.style.display = "flex";
    banner.style.display = "none";
  } else {
    overlay.style.display = "none";
    banner.style.display = "block";
  }
}

export default apiInitializer("0.11.1", (api) => {
  if (!hasWindow()) {
    return;
  }

  // Only target anonymous users
  if (api.getCurrentUser()) {
    return;
  }

  if (window.icarsoftPrelaunchInitialized) {
    return;
  }

  window.icarsoftPrelaunchInitialized = true;

  startCountdown();
  updateVisibility();

  api.onPageChange(() => {
    startCountdown();
    updateVisibility();
  });
});
