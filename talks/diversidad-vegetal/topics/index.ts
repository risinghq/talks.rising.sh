import { briofitos } from "./briofitos";
import { helechos } from "./helechos";
import { hongos } from "./hongos";
import type { Topic } from "./types";

export const topics: Topic[] = [hongos, briofitos, helechos];

export const topicBySlug = (slug: string) => topics.find((t) => t.slug === slug);
