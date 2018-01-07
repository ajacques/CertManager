/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import classNames from 'classnames';
import React from 'react';
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

global.React = React;
global.ReactDOM = ReactDOM;
global.PropTypes = PropTypes;
global.classNames = classNames;

// Legacy Component Exports
const componentRequireContext = require.context("components", true);

componentRequireContext.keys().forEach(f => {
  if (!f.endsWith('.js')) {
    window[f.substring(2)] = componentRequireContext(f).default;
  }
});
