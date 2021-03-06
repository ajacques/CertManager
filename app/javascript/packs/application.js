/* globals require, process */
import { exportRootSpanAfterLoadEvent } from '@opencensus/web-initial-load';
import RavenErrorContainer from 'utilities/RavenErrorContainer';
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
  const Sentry = require('@sentry/browser');
  const metaTag = document.querySelector('meta[name="sentry-report-uri"]');
  if (metaTag) {
    Sentry.init({
      dsn: metaTag.content,
      release: Version
    });
  }
}

const traceHost = document.querySelector('meta[name="trace-agent"]');
if (traceHost) {
  window.ocServiceName = 'WebBrowser';
  window.traceparent = document.querySelector('meta[name="opencensus-traceparent"]').content;
  window.ocAgent = traceHost.content;

  exportRootSpanAfterLoadEvent();
}

function HydrateComponent(className, props, targetElement) {
  const clazz = getComponentConstructor(className);
  ReactDOM.hydrate(React.createElement(RavenErrorContainer, null, React.createElement(clazz, props)), targetElement);
}

window.App = {
  HydrateComponent
};
