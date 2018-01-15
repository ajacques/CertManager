/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import React from 'react';
import ReactDOM from 'react-dom';
import Raven from 'raven-js';
import Version from 'environment/ReleaseVersion.js.erb';

// Legacy Component Exports
const componentRequireContext = require.context("components", true);

function GetComponentConstructor(name) {
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
  const clazz = GetComponentConstructor(className) || global[className];
  ReactDOM.hydrate(React.createElement(clazz, props), targetElement);
}

global.App = {
  HydrateComponent
};

