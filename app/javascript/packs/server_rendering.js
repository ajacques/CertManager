const componentRequireContext = require.context("components", true);
const ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);

import classNames from 'classnames';
import React from 'react';
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

global.className = classNames;
global.React = React;
global.ReactDOM = ReactDOM;
global.PropTypes = PropTypes;
