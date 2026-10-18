import type { BaseLayoutProps } from 'fumadocs-ui/layouts/shared';
import { appName, basePath, gitConfig } from './shared';

export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      // JSX supported
      title: (
        <div className="flex content-center gap-2">
          {/* Plain <img> because static export cannot optimize next/image. */}
          <img
            src={`${basePath}/nix-snowflake-colours.svg`}
            alt=""
            width={24}
            height={24}
            className="size-6 dark:hidden"
          />
          <img
            src={`${basePath}/nix-snowflake-white.svg`}
            alt=""
            width={24}
            height={24}
            className="size-6 hidden dark:block"
          />
          {appName}
        </div>
      ),
    },
    githubUrl: `https://github.com/${gitConfig.user}/${gitConfig.repo}`,
  };
}
