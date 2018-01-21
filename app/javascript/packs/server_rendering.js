/* globals require, global */
import PropTypes from "prop-types";
import React from "react";
import ReactDOM from "react-dom";
import ReactRailsUJS from "react_ujs";
import classNames from "classnames";

const componentRequireContext = require.context("components", true);
ReactRailsUJS.useContext(componentRequireContext);

global.className = classNames;
global.React = React;
global.ReactDOM = ReactDOM;
global.PropTypes = PropTypes;
