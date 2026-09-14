import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { feedRouter } from './modules/feed/feed.routes.js';
import { storiesRouter } from './modules/stories/stories.routes.js';
import { discoverRouter } from './modules/discover/discover.routes.js';
import { searchRouter } from './modules/search/search.routes.js';
import { userRouter } from './modules/user/user.routes.js';
import { errorHandler } from './shared/middleware/error-handler.js';
import { requestLogger } from './shared/middleware/request-logger.js';

const app = express();
const PORT = process.env.PORT ?? 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(requestLogger);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'pulse-api', version: '0.1.0' });
});

app.use('/api/v1/feed', feedRouter);
app.use('/api/v1/stories', storiesRouter);
app.use('/api/v1/discover', discoverRouter);
app.use('/api/v1/search', searchRouter);
app.use('/api/v1/me', userRouter);

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Pulse API running on http://localhost:${PORT}`);
});
