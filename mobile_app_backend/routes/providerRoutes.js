import express from 'express';
import { createProvider, getProviderDashboard, getProviders } from '../controllers/providerController.js';
import { protect } from "../middleware/authMiddleware.js";
import {
  authorizeRoles,
  adminOnly,
  providerOnly,
  customerOnly,
} from "../middleware/roleMiddleware.js";
import {
  createService,
} from "../controllers/serviceController.js";
const router = express.Router();

router.post('/', createProvider);
router.get('/', getProviders);
router.post(
  "/services",
  protect,
  providerOnly,
  createService
);
router.get(
  "/dashboard",
  protect,
  providerOnly,
  getProviderDashboard
);


export default router;