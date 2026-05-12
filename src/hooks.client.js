import { Temporal } from '@js-temporal/polyfill';

if (globalThis.Temporal === undefined) globalThis.Temporal = Temporal;
