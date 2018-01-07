const componentRequireContext = require.context("components", true);
const ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);

import React from 'react';
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

rootContext.React = React;
rootContext.ReactDOM = ReactDOM;
rootContext.PropTypes = PropTypes;
