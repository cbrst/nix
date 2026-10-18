import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { source } from '@/lib/source';
import { notFound } from 'next/navigation';
import { generateOGImage } from 'fumadocs-ui/og';
import { appName, getPageImageUrl } from '@/lib/shared';

export const revalidate = false;

// The generated image has a dark background, so use the white snowflake.
const logo = readFile(join(process.cwd(), 'public/nix-snowflake-white.svg'), 'base64');

export async function GET(_req: Request, { params }: RouteContext<'/og/docs/[...slug]'>) {
  const { slug } = await params;
  const page = source.getPage(slug.slice(0, -1));
  if (!page) notFound();

  return generateOGImage({
    title: page.data.title,
    description: page.data.description,
    site: appName,
    icon: <img src={`data:image/svg+xml;base64,${await logo}`} alt="" width={64} height={64} />,
  });
}

export function generateStaticParams() {
  return source.getPages().map((page) => ({
    lang: page.locale,
    slug: getPageImageUrl(page).segments,
  }));
}
