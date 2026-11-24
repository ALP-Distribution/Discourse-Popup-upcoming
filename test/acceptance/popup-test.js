import { module, test } from "qunit";
import {
  getSessionFlag,
  isAfterLaunchDate,
} from "../../javascripts/discourse/api-initializers/popup.gjs";

module("Unit | popup helpers", function () {
  test("getSessionFlag returns false when sessionStorage.getItem throws an error", function (assert) {
    const originalGetItem = window.sessionStorage.getItem;
    window.sessionStorage.getItem = function () {
      throw new Error("sessionStorage error");
    };

    try {
      assert.false(getSessionFlag(), "returns false when an error is thrown");
    } finally {
      window.sessionStorage.getItem = originalGetItem;
    }
  });

  test("getSessionFlag returns true when sessionStorage item is 'true'", function (assert) {
    const originalGetItem = window.sessionStorage.getItem;
    window.sessionStorage.getItem = function () {
      return "true";
    };

    try {
      assert.true(
        getSessionFlag(),
        "returns true when sessionStorage has 'true'"
      );
    } finally {
      window.sessionStorage.getItem = originalGetItem;
    }
  });

  test("getSessionFlag returns false when sessionStorage item is not 'true'", function (assert) {
    const originalGetItem = window.sessionStorage.getItem;
    window.sessionStorage.getItem = function () {
      return "false";
    };

    try {
      assert.false(
        getSessionFlag(),
        "returns false when sessionStorage has 'false'"
      );
    } finally {
      window.sessionStorage.getItem = originalGetItem;
    }
  });

  test("isAfterLaunchDate compares timestamps against target ISO date", function (assert) {
    const launchIso = "2025-12-15T00:00:00+01:00";
    assert.false(
      isAfterLaunchDate(new Date("2025-12-14T22:59:59Z"), launchIso),
      "returns false before launch"
    );
    assert.true(
      isAfterLaunchDate(new Date("2025-12-14T23:00:00Z"), launchIso),
      "returns true at or after launch"
    );
  });
});
