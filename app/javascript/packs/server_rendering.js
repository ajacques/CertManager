import ReactRailsUJS from 'react_ujs';

const componentRequireContext = require.context("components", true);
ReactRailsUJS.useContext(componentRequireContext);

import classNames from 'classnames';
import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

global.className = classNames;
global.React = React;
global.ReactDOM = ReactDOM;
global.PropTypes = PropTypes;
