import { module, test } from "qunit";
import { getSessionFlag } from "../../javascripts/discourse/api-initializers/popup";

module("Unit | getSessionFlag", function () {
  test("it returns false when sessionStorage.getItem throws an error", function (assert) {
    const originalGetItem = window.sessionStorage.getItem;
    window.sessionStorage.getItem = function() {
      throw new Error("sessionStorage error");
    };

    try {
      assert.strictEqual(
        getSessionFlag(),
        false,
        "returns false when an error is thrown"
      );
    } finally {
      window.sessionStorage.getItem = originalGetItem;
    }
  });

  test("it returns true when sessionStorage item is 'true'", function (assert) {
    const originalGetItem = window.sessionStorage.getItem;
    window.sessionStorage.getItem = function() {
      return "true";
    };

    try {
      assert.strictEqual(
        getSessionFlag(),
        true,
        "returns true when sessionStorage has 'true'"
      );
    } finally {
      window.sessionStorage.getItem = originalGetItem;
    }
  });

  test("it returns false when sessionStorage item is not 'true'", function (assert) {
    const originalGetItem = window.sessionStorage.getItem;
    window.sessionStorage.getItem = function() {
      return "false";
    };

    try {
      assert.strictEqual(
        getSessionFlag(),
        false,
        "returns false when sessionStorage has 'false'"
      );
    } finally {
      window.sessionStorage.getItem = originalGetItem;
    }
  });
});
