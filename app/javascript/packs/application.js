/* globals require, process */
import Raven from "raven-js";
import React from "react";
import ReactDOM from "react-dom";
import Version from "environment/ReleaseVersion.js.erb";

// Legacy Component Exports
const componentRequireContext = require.context("components", true);

function getComponentConstructor(name) {
  const context = componentRequireContext(`./${name}`);
  if (context) {
    return context.default;
  }
  return null;
}

if (process.env.NODE_ENV === 'production') {
  const metaTag = document.querySelector('meta[name="sentry-report-uri"]');
  if (metaTag) {
    Raven
      .config(metaTag.content, {
        release: Version
      })
      .install();
  }
}

function HydrateComponent(className, props, targetElement) {
  const clazz = getComponentConstructor(className);
  ReactDOM.hydrate(React.createElement(clazz, props), targetElement);
}

window.App = {
  HydrateComponent
};
